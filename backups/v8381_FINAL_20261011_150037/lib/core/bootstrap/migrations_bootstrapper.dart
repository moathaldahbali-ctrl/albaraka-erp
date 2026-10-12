import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

/// v9.4.6: فحص Migrations
class MigrationsBootstrapper {
  final Database db;
  MigrationsBootstrapper(this.db);

  /// يُرجع رقم الإصدار الحالي
  Future<int> run() async {
    final result = await db.rawQuery('PRAGMA user_version');
    final version = (result.first['user_version'] as int?) ?? 0;
    debugPrint('[MigrationsBootstrapper] user_version = $version');
    return version;
  }

  /// حفظ حالة آخر Migration في bootstrap_state
  Future<void> saveState(int version) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(
      'bootstrap_state',
      {
        'key': 'last_migration_version',
        'value': version.toString(),
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// قراءة آخر Migration محفوظ
  Future<int?> readSavedState() async {
    final rows = await db.query(
      'bootstrap_state',
      where: 'key = ?',
      whereArgs: ['last_migration_version'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return int.tryParse(rows.first['value'] as String? ?? '');
  }
}