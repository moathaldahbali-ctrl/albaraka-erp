import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'seeds/permissions_seed.dart';

/// حقن الصلاحيات والأدوار - Idempotent
class SeedRunner {
  final Database db;
  SeedRunner(this.db);

  Future<void> run() async {
    await _seedPermissions();
    await _seedRoles();
    await _seedRoleDefaults();
    print('Seed done: ${PermissionsSeed.all.length} permissions, ${PermissionsSeed.roles.length} roles');
  }

  Future<void> _seedPermissions() async {
    final batch = db.batch();
    for (final p in PermissionsSeed.all) {
      batch.insert(
        'permissions_local',
        {
          'id': p['code'],
          'code': p['code'],
          'name_ar': p['name_ar'],
          'category': p['category'],
          'sort_order': p['sort'],
          'is_active': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedRoles() async {
    final batch = db.batch();
    for (final r in PermissionsSeed.roles) {
      batch.insert(
        'roles_local',
        {
          'id': r['code'],
          'code': r['code'],
          'name_ar': r['name_ar'],
          'is_system': r['is_system'],
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedRoleDefaults() async {
    final allCodes = PermissionsSeed.all
        .map((p) => p['code'] as String)
        .toList();

    final batch = db.batch();

    // حذف كل الصلاحيات المُسبقة (لضمان Idempotency)
    batch.delete('role_permissions_local');

    for (final entry in PermissionsSeed.roleDefaults.entries) {
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
      }
    }

    await batch.commit(noResult: true);
    print('Role defaults applied: ${PermissionsSeed.roleDefaults.length} roles');
  }
}