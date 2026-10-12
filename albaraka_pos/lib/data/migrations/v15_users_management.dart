import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

// v15: User Management + Permission Overrides
// Date: 2026-10-10

class V15UsersManagement {
  static Future<void> migrate(Database db) async {
    await _addColumnIfMissing(db, 'users_local', 'display_name', 'TEXT');
    await _addColumnIfMissing(db, 'users_local', 'last_login_at', 'TEXT');
    await _addColumnIfMissing(db, 'users_local', 'is_active', 'INTEGER DEFAULT 1');
    await _addColumnIfMissing(db, 'users_local', 'synced_at', 'TEXT');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_permissions_override_local (
        user_id TEXT NOT NULL,
        permission_key TEXT NOT NULL,
        is_granted INTEGER NOT NULL DEFAULT 1,
        granted_by TEXT,
        granted_at TEXT,
        synced_at TEXT,
        PRIMARY KEY (user_id, permission_key)
      )
    ''');

    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_user_perms_synced
      ON user_permissions_override_local(synced_at)
    ''');

    debugPrint('✅ V15 Migration Complete');
  }

  static Future<void> _addColumnIfMissing(
    Database db, String table, String column, String definition) async {
    final cols = await db.rawQuery("PRAGMA table_info($table)");
    final exists = cols.any((c) => c['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
      debugPrint('✅ v15: Added $column to $table');
    }
  }
}
