import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');
  final rows = await db.rawQuery(
    'SELECT invoice_number, status, total, synced_at '
    'FROM sales_local ORDER BY created_at DESC');
  print('=== sales_local ===');
  for (final r in rows) { print(r.toString()); }
  print('');
  final pending = await db.rawQuery(
    "SELECT COUNT(*) as c FROM sales_local WHERE status='pending'");
  print('pending: ' + pending.first['c'].toString());
  await db.close();
}
