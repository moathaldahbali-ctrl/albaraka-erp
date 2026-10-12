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
  final db = await factory.openDatabase(dbPath);

  print('=== ALL TABLES ===');
  final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
  for (final t in tables) {
    print('  - ' + t['name'].toString());
  }
  print('');

  print('=== SCHEMA products_local ===');
  final cols = await db.rawQuery('PRAGMA table_info(products_local)');
  for (final c in cols) {
    print('  ' + c['name'].toString() +
          '  | type=' + c['type'].toString() +
          '  | notnull=' + c['notnull'].toString() +
          '  | pk=' + c['pk'].toString());
  }
  print('');

  print('=== SCHEMA sales_local ===');
  final scols = await db.rawQuery('PRAGMA table_info(sales_local)');
  for (final c in scols) {
    print('  ' + c['name'].toString() +
          '  | type=' + c['type'].toString() +
          '  | notnull=' + c['notnull'].toString());
  }
  print('');

  print('=== SCHEMA sale_lines_local ===');
  final lcols = await db.rawQuery('PRAGMA table_info(sale_lines_local)');
  for (final c in lcols) {
    print('  ' + c['name'].toString() +
          '  | type=' + c['type'].toString() +
          '  | notnull=' + c['notnull'].toString());
  }
  print('');

  print('=== ROW COUNTS ===');
  for (final t in ['products_local', 'currencies_local', 'sales_local',
                   'sale_lines_local']) {
    try {
      final r = await db.rawQuery('SELECT COUNT(*) AS c FROM ' + t);
      print('  ' + t + ': ' + r.first['c'].toString());
    } catch (e) {
      print('  ' + t + ': (missing)');
    }
  }

  print('');
  print('=== PRAGMA user_version ===');
  final v = await db.rawQuery('PRAGMA user_version');
  print('  version = ' + v.first['user_version'].toString());

  await db.close();
  print('');
  print('DONE.');
}
