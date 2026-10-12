import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');

  print('=== sale_lines_local (pending sales) ===');
  final rows = await db.rawQuery('''
    SELECT sl.sale_id, sl.product_id, sl.product_name,
           p.unit_id AS product_unit_id_in_products_local
    FROM sale_lines_local sl
    LEFT JOIN products_local p ON p.id = sl.product_id
  ''');
  for (final r in rows) { print(r.toString()); }

  print('');
  print('=== products_local.unit_id values (sample) ===');
  final units = await db.rawQuery(
    'SELECT DISTINCT unit_id FROM products_local LIMIT 10');
  for (final r in units) { print('  ' + r['unit_id'].toString()); }

  await db.close();
}
