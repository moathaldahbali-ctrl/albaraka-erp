import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final dbPath = r'D:\albaraka\data\albaraka_local.db';
  if (!File(dbPath).existsSync()) { print('DB not found'); exit(1); }

  final probe = await factory.openDatabase(dbPath);
  final cur = (await probe.rawQuery('PRAGMA user_version')).first['user_version'] as int;
  print('Current: v' + cur.toString());
  await probe.close();

  if (cur >= 9) { print('Already v9+.'); return; }

  final db = await factory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 9,
      onUpgrade: (d, oldV, newV) async {
        print('Upgrading: v' + oldV.toString() + ' -> v' + newV.toString());
        if (oldV < 9) {
          await d.execute('''
            CREATE TABLE IF NOT EXISTS drafts_local (
              key TEXT PRIMARY KEY,
              value TEXT NOT NULL,
              updated_at TEXT NOT NULL
            )
          ''');
          print('  drafts_local created');
        }
      },
    ),
  );
  print('Now: v' + (await db.rawQuery('PRAGMA user_version')).first['user_version'].toString());
  await db.close();
  print('DONE.');
}
