import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'seeds/permissions_seed.dart';

/// حقن الصلاحيات والأدوار - Idempotent
class SeedRunner {
  final Database db;
  SeedRunner(this.db);

  Future<void> run() async {
    await _seedPermissions();
    await _seedRoles();
    await _seedCashierPermissions();
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

  Future<void> _seedCashierPermissions() async {
    final batch = db.batch();
    for (final code in PermissionsSeed.cashierPermissions) {
      batch.insert(
        'role_permissions_local',
        {
          'role_id': 'Cashier',
          'permission_id': code,
          'allowed': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }
}