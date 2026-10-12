import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';
import 'seeds/permissions_seed.dart';

/// حقن الصلاحيات والأدوار - Idempotent
/// v9.4.6: يستخدم allExtended + allRoleAssignments
class SeedRunner {
  final Database db;
  SeedRunner(this.db);

  Future<void> run() async {
    await _seedPermissions();
    await _seedRoles();
    await _seedRoleDefaults();

    debugPrint(
      '[SeedRunner] ${PermissionsSeed.seedVersion} (gen ${PermissionsSeed.seedGeneration}): '
      '${PermissionsSeed.allExtended.length} permissions, '
      '${PermissionsSeed.roles.length} roles',
    );
  }

  Future<void> _seedPermissions() async {
    final batch = db.batch();
    for (final p in PermissionsSeed.allExtended) {
      // دعم code (all) و key (masterData/userProfile)
      final id = p['code'] ?? p['key'];
      batch.insert(
        'permissions_local',
        {
          'id': id,
          'code': id,
          'name_ar': p['name_ar'] ?? p['name_en'] ?? id,
          'category': p['category'] ?? 'unknown',
          'sort_order': p['sort'] ?? 0,
          'is_active': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    debugPrint('[SeedRunner] Permissions: ${PermissionsSeed.allExtended.length}');
  }

  Future<void> _seedRoles() async {
    final batch = db.batch();
    for (final r in PermissionsSeed.roles) {
      final id = r['code'] ?? r['id'];
      batch.insert(
        'roles_local',
        {
          'id': id,
          'code': id,
          'name_ar': r['name_ar'] ?? id,
          'is_system': r['is_system'] ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
    debugPrint('[SeedRunner] Roles: ${PermissionsSeed.roles.length}');
  }

  Future<void> _seedRoleDefaults() async {
    // كل الصلاحيات المتاحة (للتوسيع *ALL*)
    final allCodes = PermissionsSeed.allExtended
        .map((p) => (p['code'] ?? p['key']) as String)
        .toList();

    final batch = db.batch();

    // حذف كل التعيينات القديمة (Idempotency)
    batch.delete('role_permissions_local');

    // استخدام allRoleAssignments (مدموجة + معالجة *ALL*)
    final assignments = PermissionsSeed.allRoleAssignments;

    int totalInserted = 0;
    for (final entry in assignments.entries) {
      final roleId = entry.key;
      final codes = (entry.value.length == 1 && entry.value.first == '*ALL*')
          ? allCodes
          : entry.value;

      for (final code in codes) {
        batch.insert(
          'role_permissions_local',
          {'role_id': roleId, 'permission_id': code, 'allowed': 1},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        totalInserted++;
      }
    }

    await batch.commit(noResult: true);
    debugPrint(
      '[SeedRunner] Role assignments: $totalInserted rows across ${assignments.length} roles',
    );
  }
}