import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(r'D:\albaraka\data\albaraka_local.db');

  // قائمة الجداول
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
  );
  print('TABLES:');
  for (final t in tables) {
    print('  - ' + t['name'].toString());
  }
  print('');

  // بنية products_local
  print('SCHEMA products_local:');
  final cols = await db.rawQuery('PRAGMA table_info(products_local)');
  for (final c in cols) {
    print('  ' + c['name'].toString() + ' | ' + c['type'].toString() +
          ' | notnull=' + c['notnull'].toString());
  }
  print('');

  // عدد الصفوف
  final cnt = await db.rawQuery('SELECT COUNT(*) as c FROM products_local');
  print('products_local rows: ' + cnt.first['c'].toString());

  await db.close();
}
