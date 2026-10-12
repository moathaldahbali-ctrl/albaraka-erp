import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db',
  );
  final del1 = await db.delete(
    'product_units_local',
    where: "product_id IN (SELECT id FROM products_local WHERE sku LIKE 'SKU-%')",
  );
  final del2 = await db.delete(
    'products_local',
    where: "sku LIKE 'SKU-%'",
  );
  print('Deleted units: ' + del1.toString());
  print('Deleted products: ' + del2.toString());
  await db.close();
}
