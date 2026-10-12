import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db',
  );
  final total = await db.rawQuery('SELECT COUNT(*) as c FROM products_local');
  final newOnes = await db.rawQuery(
    "SELECT COUNT(*) as c FROM products_local WHERE sku LIKE 'SKU-%'");
  final units = await db.rawQuery('SELECT COUNT(*) as c FROM product_units_local');
  print('products_local total: ' + total.first['c'].toString());
  print('products_local SKU-*: ' + newOnes.first['c'].toString());
  print('product_units_local total: ' + units.first['c'].toString());
  await db.close();
}
