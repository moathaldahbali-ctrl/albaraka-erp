import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// خدمة قراءة الصلاحيات
class PermissionService {
  final Database db;
  PermissionService(this.db);

  /// هل المستخدم يملك صلاحية معينة؟
  Future<bool> hasPermission(String userId, String code) async {
    final userOverride = await db.query(
      'user_permissions_local',
      where: 'user_id = ? AND permission_id = ?',
      whereArgs: [userId, code],
      limit: 1,
    );
    if (userOverride.isNotEmpty) {
      return userOverride.first['allowed'] == 1;
    }

    final result = await db.rawQuery('''
      SELECT rp.allowed
      FROM role_permissions_local rp
      JOIN user_roles_local ur ON ur.role_id = rp.role_id
      WHERE ur.user_id = ? AND rp.permission_id = ?
      LIMIT 1
    ''', [userId, code]);

    return result.isNotEmpty && result.first['allowed'] == 1;
  }

  /// كل صلاحيات المستخدم
  Future<Set<String>> getPermissions(String userId) async {
    final result = await db.rawQuery('''
      SELECT DISTINCT rp.permission_id, rp.allowed
      FROM role_permissions_local rp
      JOIN user_roles_local ur ON ur.role_id = rp.role_id
      WHERE ur.user_id = ? AND rp.allowed = 1
    ''', [userId]);
    return result.map((r) => r['permission_id'] as String).toSet();
  }

  /// الصلاحيات حسب القسم
  Future<List<Map<String, dynamic>>> byCategory(String category) async {
    return db.query(
      'permissions_local',
      where: 'category = ? AND is_active = 1',
      whereArgs: [category],
      orderBy: 'sort_order ASC',
    );
  }

  /// كل الأدوار
  Future<List<Map<String, dynamic>>> getRoles() async {
    return db.query('roles_local', orderBy: 'name_ar ASC');
  }

  /// صلاحيات دور معين (المسموح بها فقط)
  Future<Set<String>> getRolePermissions(String roleId) async {
    final rows = await db.query(
      'role_permissions_local',
      where: 'role_id = ? AND allowed = 1',
      whereArgs: [roleId],
    );
    return rows.map((r) => r['permission_id'] as String).toSet();
  }

  /// حفظ صلاحيات دور (استبدال كامل داخل transaction)
  Future<void> setRolePermissions(String roleId, Set<String> codes) async {
    await db.transaction((txn) async {
      await txn.delete(
        'role_permissions_local',
        where: 'role_id = ?',
        whereArgs: [roleId],
      );
      final batch = txn.batch();
      for (final code in codes) {
        batch.insert(
          'role_permissions_local',
          {'role_id': roleId, 'permission_id': code, 'allowed': 1},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }
}