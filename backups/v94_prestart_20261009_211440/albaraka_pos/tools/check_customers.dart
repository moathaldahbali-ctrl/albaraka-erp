import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final dbPath = r'D:\albaraka\data\albaraka_local.db';
  if (!File(dbPath).existsSync()) {
    print('ERROR: DB not found at $dbPath');
    exit(1);
  }
  final db = await databaseFactoryFfi.openDatabase(dbPath);

  print('=== Tables ===');
  final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name");
  for (final t in tables) { print('  ${t['name']}'); }

  print('');
  print('=== customers_local ===');
  try {
    final count = await db.rawQuery('SELECT COUNT(*) as c FROM customers_local');
    print('  COUNT: ${count.first['c']}');
    print('');
    print('  First 5:');
    final rows = await db.rawQuery('SELECT code, name, phone FROM customers_local ORDER BY CAST(code AS INTEGER) LIMIT 5');
    for (final r in rows) {
      print('    ${r['code']} | ${r['name']} | ${r['phone']}');
    }
  } catch (e) {
    print('  ERROR: $e');
  }
  await db.close();
}