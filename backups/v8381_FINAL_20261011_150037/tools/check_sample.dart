import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');
  final rows = await db.rawQuery(
    'SELECT sku, name, category_slug, unit_id, sale_price, stock_qty '
    'FROM products_local LIMIT 5');
  for (final r in rows) { print(r.toString()); }
  print('');
  final cats = await db.rawQuery(
    'SELECT COUNT(DISTINCT category_slug) as c FROM products_local');
  print('distinct categories: ' + cats.first['c'].toString());
  await db.close();
}
