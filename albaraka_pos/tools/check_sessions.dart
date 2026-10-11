import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await databaseFactory.openDatabase(
    r'D:\albaraka\data\albaraka_local.db',
  );

  print('=== Current DB version ===');
  final v = await db.getVersion();
  print('  version = $v');

  print('');
  print('=== Tables matching "register%" ===');
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'register%'"
  );
  if (tables.isEmpty) {
    print('  (none)');
  } else {
    for (final t in tables) print('  ${t['name']}');
  }

  print('');
  print('=== register_sessions_local columns ===');
  final cols = await db.rawQuery('PRAGMA table_info(register_sessions_local)');
  if (cols.isEmpty) {
    print('  TABLE MISSING');
  } else {
    for (final c in cols) {
      print('  ${c['name']} | ${c['type']} | notnull=${c['notnull']} | pk=${c['pk']}');
    }
  }

  print('');
  print('=== Indices ===');
  final idx = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='register_sessions_local'"
  );
  if (idx.isEmpty) {
    print('  (none)');
  } else {
    for (final i in idx) print('  ${i['name']}');
  }

  print('');
  final n = await db.rawQuery('SELECT COUNT(*) AS n FROM register_sessions_local');
  print('Rows: ${n.first['n']}');

  await db.close();
}