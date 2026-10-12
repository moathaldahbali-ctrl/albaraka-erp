// migrate_v6.dart
// Standalone migration: v5 -> v6 (no Flutter imports, pure Dart)

import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final dbPath = r'D:\albaraka\data\albaraka_local.db';

  if (!File(dbPath).existsSync()) {
    print('DB NOT FOUND: ' + dbPath);
    exit(1);
  }

  // افحص الإصدار الحالي
  final probe = await factory.openDatabase(dbPath);
  final v = await probe.rawQuery('PRAGMA user_version');
  final currentVersion = v.first['user_version'] as int;
  print('Current version: ' + currentVersion.toString());

  if (currentVersion >= 6) {
    print('Already at v6 or later. Nothing to do.');
    await probe.close();
    return;
  }

  // أغلق الفتح الأول
  await probe.close();

  // افتح بالإصدار 6 + onUpgrade
  final db = await factory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 6,
      onUpgrade: (d, oldV, newV) async {
        print('Upgrading from ' + oldV.toString() + ' to ' + newV.toString());
        if (oldV < 6) {
          print('  Adding category_slug...');
          await d.execute('ALTER TABLE products_local ADD COLUMN category_slug TEXT');
          print('  Adding stock_qty...');
          await d.execute('ALTER TABLE products_local ADD COLUMN stock_qty REAL');
        }
      },
    ),
  );

  print('');
  print('=== After upgrade ===');
  final v2 = await db.rawQuery('PRAGMA user_version');
  print('user_version = ' + v2.first['user_version'].toString());

  print('');
  print('products_local columns:');
  final cols = await db.rawQuery('PRAGMA table_info(products_local)');
  for (final c in cols) {
    print('  ' + c['name'].toString() + ' | ' + c['type'].toString());
  }

  print('');
  final cnt = await db.rawQuery('SELECT COUNT(*) as c FROM products_local');
  print('products_local rows: ' + cnt.first['c'].toString());

  await db.close();
  print('');
  print('DONE.');
}
