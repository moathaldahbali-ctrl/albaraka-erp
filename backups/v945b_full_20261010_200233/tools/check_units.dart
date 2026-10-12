import 'package:sqflite_common_ffi/sqflite_ffi.dart';
void main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');

  final cnt = await db.rawQuery('SELECT COUNT(*) as c FROM product_units_local');
  print('total units: ' + cnt.first['c'].toString());

  print('');
  print('=== وحدات حليب بقري (02-048) ===');
  final rows = await db.rawQuery('''
    SELECT p.sku, p.name, u.unit_code, u.conversion_factor, u.is_default
    FROM product_units_local u
    JOIN products_local p ON p.id = u.product_id
    WHERE p.sku IN ('01-127', '05-121', '02-048', '21-480')
    ORDER BY p.sku, u.conversion_factor
  ''');
  for (final r in rows) { print('  ' + r.toString()); }

  await db.close();
}
