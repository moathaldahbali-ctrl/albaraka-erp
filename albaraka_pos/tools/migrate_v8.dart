// migrate_v8.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final dbPath = r'D:\albaraka\data\albaraka_local.db';
  if (!File(dbPath).existsSync()) { print('DB not found'); exit(1); }

  final probe = await factory.openDatabase(dbPath);
  final v = await probe.rawQuery('PRAGMA user_version');
  final cur = v.first['user_version'] as int;
  print('Current: v' + cur.toString());
  await probe.close();

  if (cur >= 8) { print('Already v8+.'); return; }

  final db = await factory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 8,
      onUpgrade: (d, oldV, newV) async {
        print('Upgrading: v' + oldV.toString() + ' -> v' + newV.toString());
        if (oldV < 8) {
          await d.execute('''
            CREATE TABLE IF NOT EXISTS categories_local (
              slug TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              synced_at TEXT NOT NULL
            )
          ''');
          print('  categories_local created');
        }
      },
    ),
  );

  final v2 = await db.rawQuery('PRAGMA user_version');
  print('Now: v' + v2.first['user_version'].toString());
  await db.close();
  print('DONE.');
}
