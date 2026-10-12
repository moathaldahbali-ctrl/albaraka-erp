// load_products_to_sqlite.dart
import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const HASURA_URL =
    'https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql';

String readAdminSecret() {
  final env = File(r'D:\albaraka\albaraka_pos\.env');
  if (!env.existsSync()) { print('ERROR: .env not found'); exit(1); }
  for (final line in env.readAsLinesSync()) {
    final t = line.trim();
    if (t.startsWith('HASURA_ADMIN_SECRET=')) {
      return t.substring('HASURA_ADMIN_SECRET='.length).trim();
    }
  }
  print('ERROR: HASURA_ADMIN_SECRET not found');
  exit(1);
}

Future<Map<String, dynamic>> graphql(String secret, String query) async {
  final client = HttpClient();
  final req = await client.postUrl(Uri.parse(HASURA_URL));
  req.headers.set('content-type', 'application/json');
  req.headers.set('x-hasura-admin-secret', secret);
  req.write(jsonEncode({'query': query}));
  final resp = await req.close();
  final body = await resp.transform(utf8.decoder).join();
  client.close();
  final data = jsonDecode(body) as Map<String, dynamic>;
  if (data['errors'] != null) {
    print('GraphQL errors: ' + data['errors'].toString());
    exit(1);
  }
  return data['data'] as Map<String, dynamic>;
}

void main() async {
  final secret = readAdminSecret();
  print('Secret length: ' + secret.length.toString());

  print('Fetching products from Hasura...');
  final data = await graphql(secret, r'''
    query {
      products(order_by: {name: asc}) {
        id sku name standard_cost sale_price
        category { slug }
        product_units { unit_code }
        stock_balances(where: {warehouse_id: {_eq: "33333333-3333-3333-3333-333333333333"}}) {
          quantity
        }
      }
    }
  ''');

  final products = (data['products'] as List).cast<Map<String, dynamic>>();
  print('Fetched ' + products.length.toString() + ' products');

  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final db = await factory.openDatabase(r'D:\albaraka\data\albaraka_local.db');

  final before = await db.rawQuery('SELECT COUNT(*) as c FROM products_local');
  print('Before: ' + before.first['c'].toString());

  await db.transaction((txn) async {
    await txn.delete('products_local');
    final batch = txn.batch();
    final now = DateTime.now().toIso8601String();
    int i = 0;
    for (final p in products) {
      final category = p['category'] != null
          ? (p['category'] as Map)['slug'] as String? : null;
      final units = p['product_units'] as List?;
      final unitCode = (units != null && units.isNotEmpty)
          ? (units.first as Map)['unit_code'] as String? : null;
      final stocks = p['stock_balances'] as List?;
      final stockQty = (stocks != null && stocks.isNotEmpty)
          ? ((stocks.first as Map)['quantity'] as num).toDouble() : null;

      batch.insert('products_local', {
        'id': p['id'],
        'name': p['name'],
        'sku': p['sku'],
        'standard_cost': (p['standard_cost'] as num).toDouble(),
        'sale_price': (p['sale_price'] as num).toDouble(),
        'unit_id': unitCode,
        'category_slug': category,
        'stock_qty': stockQty,
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      i++;
      if (i % 500 == 0) print('  staged ' + i.toString());
    }
    await batch.commit(noResult: true);
  });

  final after = await db.rawQuery('SELECT COUNT(*) as c FROM products_local');
  print('After: ' + after.first['c'].toString());

  print('');
  print('=== Sample (first 3) ===');
  final sample = await db.rawQuery(
    'SELECT sku, name, category_slug, unit_id, sale_price, stock_qty '
    'FROM products_local ORDER BY name LIMIT 3');
  for (final r in sample) { print('  ' + r.toString()); }

  print('');
  print('=== Category distribution ===');
  final cats = await db.rawQuery(
    'SELECT category_slug, COUNT(*) as c FROM products_local '
    'GROUP BY category_slug ORDER BY c DESC');
  for (final r in cats) {
    print('  ' + r['category_slug'].toString() + ': ' + r['c'].toString());
  }

  await db.close();
  print('');
  print('DONE.');
}
