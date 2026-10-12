import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import '../../data/seeds/permissions_seed.dart';
import '../../data/seed_runner.dart';

/// v9.4.6: فحص وتشغيل SeedRunner إذا لزم
class PermissionsBootstrapper {
  final Database db;
  PermissionsBootstrapper(this.db);

  /// يُرجع true إذا شُغّل Seed (نسخة جديدة) أو false إذا لا حاجة
  Future<bool> run() async {
    // 1) اقرأ seedVersion المحفوظ
    final savedVersion = await _readState('last_seed_version');
    final savedGeneration = await _readState('last_seed_generation');

    final currentVersion = PermissionsSeed.seedVersion;
    final currentGeneration = PermissionsSeed.seedGeneration.toString();

    // 2) افحص عدد الصلاحيات في SQLite
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as c FROM permissions_local',
    );
    final dbCount = (countResult.first['c'] as int?) ?? 0;
    final expectedCount = PermissionsSeed.allExtended.length;

    // 3) قرار
    final needsSeed = savedVersion != currentVersion ||
        savedGeneration != currentGeneration ||
        dbCount != expectedCount;

    if (!needsSeed) {
      debugPrint(
        '[PermissionsBootstrapper] Skipped — '
        'version=$currentVersion, gen=$currentGeneration, count=$dbCount',
      );
      return false;
    }

    debugPrint(
      '[PermissionsBootstrapper] Running Seed — '
      'db=$dbCount/$expectedCount, '
      'version=$savedVersion → $currentVersion, '
      'gen=$savedGeneration → $currentGeneration',
    );

    // 4) شغّل SeedRunner
    final runner = SeedRunner(db);
    await runner.run();

    // 5) احفظ الحالة
    await _saveState('last_seed_version', currentVersion);
    await _saveState('last_seed_generation', currentGeneration);

    // 6) تحقق
    final afterResult = await db.rawQuery(
      'SELECT COUNT(*) as c FROM permissions_local',
    );
    final afterCount = (afterResult.first['c'] as int?) ?? 0;
    debugPrint('[PermissionsBootstrapper] Done — count=$afterCount');

    return true;
  }

  /// يُرجع عدد الصلاحيات الحالية
  Future<int> countPermissions() async {
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM permissions_local');
    return (r.first['c'] as int?) ?? 0;
  }

  /// يُرجع عدد الأدوار
  Future<int> countRoles() async {
    final r = await db.rawQuery('SELECT COUNT(*) as c FROM roles_local');
    return (r.first['c'] as int?) ?? 0;
  }

  /// يُرجع عدد التعيينات
  Future<int> countRoleAssignments() async {
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM role_permissions_local',
    );
    return (r.first['c'] as int?) ?? 0;
  }

  Future<String?> _readState(String key) async {
    final rows = await db.query(
      'bootstrap_state',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> _saveState(String key, String value) async {
    await db.insert(
      'bootstrap_state',
      {
        'key': key,
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}