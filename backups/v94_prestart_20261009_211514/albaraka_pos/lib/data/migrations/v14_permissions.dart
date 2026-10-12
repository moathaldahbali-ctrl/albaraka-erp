import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// v9.4.2 — Schema v13 → v14
/// القاعدة: Additive Only — لا DROP، لا ALTER على أعمدة موجودة
/// المرجع: صلاحيات BetaSys الكاملة (6 أقسام، 206 صلاحية)
Future<void> migrateV13ToV14(Database db) async {
  final batch = db.batch();

  // 1. جدول الصلاحيات (Master)
  batch.execute('''
    CREATE TABLE IF NOT EXISTS permissions_local (
      id TEXT PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      name_ar TEXT NOT NULL,
      category TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_active INTEGER NOT NULL DEFAULT 1,
      synced_at TEXT
    )
  ''');

  // 2. جدول الأدوار
  batch.execute('''
    CREATE TABLE IF NOT EXISTS roles_local (
      id TEXT PRIMARY KEY,
      code TEXT NOT NULL UNIQUE,
      name_ar TEXT NOT NULL,
      description TEXT,
      is_system INTEGER NOT NULL DEFAULT 0,
      synced_at TEXT
    )
  ''');

  // 3. ربط الدور بالصلاحية
  batch.execute('''
    CREATE TABLE IF NOT EXISTS role_permissions_local (
      role_id TEXT NOT NULL,
      permission_id TEXT NOT NULL,
      allowed INTEGER NOT NULL DEFAULT 1,
      synced_at TEXT,
      PRIMARY KEY (role_id, permission_id),
      FOREIGN KEY (role_id) REFERENCES roles_local(id) ON DELETE CASCADE,
      FOREIGN KEY (permission_id) REFERENCES permissions_local(id) ON DELETE CASCADE
    )
  ''');

  // 4. صلاحيات فردية للمستخدم
  batch.execute('''
    CREATE TABLE IF NOT EXISTS user_permissions_local (
      user_id TEXT NOT NULL,
      permission_id TEXT NOT NULL,
      allowed INTEGER NOT NULL DEFAULT 1,
      synced_at TEXT,
      PRIMARY KEY (user_id, permission_id),
      FOREIGN KEY (permission_id) REFERENCES permissions_local(id) ON DELETE CASCADE
    )
  ''');

  // 5. ربط المستخدم بالدور
  batch.execute('''
    CREATE TABLE IF NOT EXISTS user_roles_local (
      user_id TEXT NOT NULL,
      role_id TEXT NOT NULL,
      synced_at TEXT,
      PRIMARY KEY (user_id, role_id),
      FOREIGN KEY (role_id) REFERENCES roles_local(id) ON DELETE CASCADE
    )
  ''');

  // 6. فهارس
  batch.execute('CREATE INDEX IF NOT EXISTS idx_permissions_category ON permissions_local(category)');
  batch.execute('CREATE INDEX IF NOT EXISTS idx_permissions_code ON permissions_local(code)');
  batch.execute('CREATE INDEX IF NOT EXISTS idx_role_perm_role ON role_permissions_local(role_id)');
  batch.execute('CREATE INDEX IF NOT EXISTS idx_user_perm_user ON user_permissions_local(user_id)');
  batch.execute('CREATE INDEX IF NOT EXISTS idx_user_roles_user ON user_roles_local(user_id)');

  await batch.commit(noResult: true);
}