import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/local_db.dart';
import 'bootstrap/bootstrap_result.dart';
import 'bootstrap/migrations_bootstrapper.dart';
import 'bootstrap/permissions_bootstrapper.dart';
import 'bootstrap/health_check_bootstrapper.dart';
import 'bootstrap/sync_bootstrapper.dart';

/// v9.4.6: المُشغّل الرئيسي عند إقلاع التطبيق
/// يشبه systemd/init على Linux — Self-Healing Bootstrap
///
/// خطوات التشغيل:
///  1. فتح SQLite
///  2. Migration check
///  3. Seed check (permissions/roles)
///  4. Health check (Hasura ping)
///  5. Sync pending (sales/sessions)
///  6. تسجيل النتيجة في bootstrap_state
class AppInitializer {
  AppInitializer._();
  static final AppInitializer instance = AppInitializer._();

  /// تشغيل Bootstrap الكامل
  ///
  /// [client] — GraphQLClient (gqlClient من main.dart)
  /// [enableSync] — هل نشغّل مزامنة العناصر المعلّقة؟
  Future<BootstrapResult> run({
    required GraphQLClient client,
    bool enableSync = true,
  }) async {
    final startedAt = DateTime.now();
    final sw = Stopwatch()..start();

    debugPrint('╔══════════════════════════════════════════════');
    debugPrint('║ [AppInitializer] Starting Bootstrap...');
    debugPrint('╚══════════════════════════════════════════════');

    try {
      // ── 1) فتح SQLite ──
      debugPrint('[AppInitializer] 1/5 Opening SQLite...');
      final db = await LocalDatabase.instance.database;
      debugPrint('[AppInitializer] SQLite ready');

      // ── 2) Migration check ──
      debugPrint('[AppInitializer] 2/5 Checking migrations...');
      final migrator = MigrationsBootstrapper(db);
      final migrationVersion = await migrator.run();
      await migrator.saveState(migrationVersion);

      // ── 3) Seed check ──
      debugPrint('[AppInitializer] 3/5 Checking permissions seed...');
      final permBoot = PermissionsBootstrapper(db);
      final didSeed = await permBoot.run();

      final permissionsCount = await permBoot.countPermissions();
      final rolesCount = await permBoot.countRoles();
      final roleAssignmentsCount = await permBoot.countRoleAssignments();

      debugPrint(
        '[AppInitializer] Seed done: '
        'perms=$permissionsCount, roles=$rolesCount, assigns=$roleAssignmentsCount',
      );

      // ── 4) Health check ──
      debugPrint('[AppInitializer] 4/5 Health check (Hasura)...');
      final healthBoot = HealthCheckBootstrapper(client: client, db: db);
      final health = await healthBoot.run();

      // ── 5) Sync (اختياري) ──
      debugPrint('[AppInitializer] 5/5 Sync pending...');
      final syncBoot = SyncBootstrapper(client: client, db: db);
      final syncSummary = await syncBoot.run(enabled: enableSync && health.isOnline);

      // ── 6) حفظ وقت آخر Bootstrap ──
      await db.insert(
        'bootstrap_state',
        {
          'key': 'last_bootstrap_at',
          'value': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      sw.stop();
      debugPrint(
        '╔══════════════════════════════════════════════\n'
        '║ [AppInitializer] Bootstrap DONE in ${sw.elapsedMilliseconds}ms\n'
        '║   migrationsRan: $didSeed\n'
        '║   permissions: $permissionsCount\n'
        '║   roles: $rolesCount\n'
        '║   assignments: $roleAssignmentsCount\n'
        '║   hasura: ${health.isOnline ? "online" : "offline"}\n'
        '║   synced: ${syncSummary.synced}, failed: ${syncSummary.failed}\n'
        '╚══════════════════════════════════════════════',
      );

      // ── 7) القرار النهائي ──
      if (health.isOnline) {
        return BootstrapResult(
          status: BootstrapStatus.success,
          migrationsRan: didSeed,
          permissionsCount: permissionsCount,
          rolesCount: rolesCount,
          roleAssignmentsCount: roleAssignmentsCount,
          hasuraOnline: true,
          pendingSynced: syncSummary.synced,
          pendingFailed: syncSummary.failed,
          startedAt: startedAt,
          finishedAt: DateTime.now(),
        );
      } else {
        // محلي يعمل — Hasura أوفلاين
        return BootstrapResult.partial(
          startedAt: startedAt,
          permissionsCount: permissionsCount,
          rolesCount: rolesCount,
          roleAssignmentsCount: roleAssignmentsCount,
          warning: 'Hasura offline — working locally',
        );
      }
    } catch (e, stackTrace) {
      sw.stop();
      debugPrint('[AppInitializer] ❌ FAILED: $e');
      debugPrint('[AppInitializer] Stack: $stackTrace');
      return BootstrapResult.failed(
        'Bootstrap failed: $e',
        startedAt: startedAt,
      );
    }
  }

  /// فحص سريع (بدون seed/sync) — للتشغيل الثاني
  Future<bool> isUpToDate() async {
    try {
      final db = await LocalDatabase.instance.database;
      final rows = await db.query(
        'bootstrap_state',
        where: 'key = ?',
        whereArgs: ['last_bootstrap_at'],
        limit: 1,
      );
      return rows.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}