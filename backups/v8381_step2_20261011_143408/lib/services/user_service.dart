import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import '../db/local_db.dart';
import '../models/user_model.dart';

class UserService {
  final LocalDatabase _db;
  final _uuid = const Uuid();

  UserService(this._db);

  static String generateSalt() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    return base64Url.encode(bytes);
  }

  static String hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  /// جلب كل المستخدمين مع أدوارهم
  Future<List<UserModel>> getAllUsers({bool includeInactive = false}) async {
    final db = await _db.database;
    final where = includeInactive ? '' : 'WHERE u.is_active = 1';
    final rows = await db.rawQuery('''
      SELECT 
        u.*,
        r.id as role_id,
        r.name as role_name
      FROM users_local u
      LEFT JOIN user_roles_local ur ON ur.user_id = u.id
      LEFT JOIN roles_local r ON r.id = ur.role_id
      $where
      ORDER BY u.username
    ''');
    return rows.map((r) => UserModel.fromMap(r)).toList();
  }

  /// جلب كل الأدوار
  Future<List<RoleModel>> getAllRoles() async {
    final db = await _db.database;
    final rows = await db.query('roles_local', orderBy: 'name');
    return rows.map((r) => RoleModel.fromMap(r)).toList();
  }

  /// إضافة مستخدم جديد (يُدخل في جدولين: users_local + user_roles_local)
  Future<String> createUser({
    required String username,
    required String pin,
    required String roleId,
    required String displayName,
  }) async {
    final db = await _db.database;
    final salt = generateSalt();
    final pinHash = hashPin(pin, salt);
    final now = DateTime.now().toIso8601String();
    final userId = _uuid.v4();

    await db.transaction((txn) async {
      await txn.insert('users_local', {
        'id': userId,
        'username': username,
        'display_name': displayName,
        'email': '$username@albaraka.local',
        'branch_id': '11111111-1111-1111-1111-111111111111',
        'pin_hash': pinHash,
        'pin_salt': salt,
        'is_active': 1,
        'failed_attempts': 0,
        'created_at': now,
        'synced_at': null,
      });

      await txn.insert('user_roles_local', {
        'user_id': userId,
        'role_id': roleId,
      });
    });

    return userId;
  }

  /// تعديل المستخدم (تحديث الاسم + الدور)
  Future<int> updateUser(String userId, {String? displayName, String? roleId}) async {
    final db = await _db.database;
    int updated = 0;

    await db.transaction((txn) async {
      // تحديث الاسم إذا تغير
      if (displayName != null) {
        updated += await txn.update(
          'users_local',
          {'display_name': displayName, 'synced_at': null},
          where: 'id = ?',
          whereArgs: [userId],
        );
      }

      // تحديث الدور
      if (roleId != null) {
        await txn.delete('user_roles_local',
            where: 'user_id = ?', whereArgs: [userId]);
        await txn.insert('user_roles_local', {
          'user_id': userId,
          'role_id': roleId,
        });
        updated++;
      }
    });

    return updated;
  }

  /// إعادة تعيين PIN
  Future<int> resetPin(String userId, String newPin) async {
    final db = await _db.database;
    final salt = generateSalt();
    final pinHash = hashPin(newPin, salt);
    return db.update(
      'users_local',
      {
        'pin_hash': pinHash,
        'pin_salt': salt,
        'failed_attempts': 0,
        'locked_until': null,
        'synced_at': null,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  /// تعطيل/تفعيل المستخدم
  Future<int> toggleActive(String userId, bool isActive) async {
    final db = await _db.database;
    return db.update(
      'users_local',
      {'is_active': isActive ? 1 : 0, 'synced_at': null},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
