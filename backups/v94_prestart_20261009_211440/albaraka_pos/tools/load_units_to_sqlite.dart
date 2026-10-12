// load_units_to_sqlite.dart
import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

const HASURA_URL =
    'https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql';

String readSecret() {
  final env = File(r'D:\albaraka\albaraka_pos\.env');
  for (final line in env.readAsLinesSync()) {
    final t = line.trim();
    if (t.startsWith('HASURA_ADMIN_SECRET=')) {
      return t.substring('HASURA_ADMIN_SECRET='.length).trim();
    }
  }
  exit(1);
}

Future<Map<String, dynamic>> gql(String s, String q) async {
  final c = HttpClient();
  final r = await c.postUrl(Uri.parse(HASURA_URL));
  r.headers.set('content-type', 'application/json');
  r.headers.set('x-hasura-admin-secret', s);
  r.write(jsonEncode({'query': q}));
  final resp = await r.close();
  final body = await resp.transform(utf8.decoder).join();
  c.close();
  final d = jsonDecode(body) as Map<String, dynamic>;
  if (d['errors'] != null) { print(d['errors']); exit(1); }
  return d['data'] as Map<String, dynamic>;
}

void main() async {
  final secret = readSecret();
  print('Fetching product_units...');

  final data = await gql(secret, r'''
    query {
      product_units(order_by: {product_id: asc}) {
        id product_id unit_code conversion_factor is_default
      }
    }
  ''');

  final units = (data['product_units'] as List).cast<Map<String, dynamic>>();
  print('Fetched ' + units.length.toString() + ' units');

  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');

  await db.transaction((txn) async {
    await txn.delete('product_units_local');
    final b = txn.batch();
    final now = DateTime.now().toIso8601String();
    for (final u in units) {
      b.insert('product_units_local', {
        'id': u['id'],
        'product_id': u['product_id'],
        'unit_code': u['unit_code'],
        'conversion_factor': (u['conversion_factor'] as num).toDouble(),
        'is_default': (u['is_default'] == true) ? 1 : 0,
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await b.commit(noResult: true);
  });

  final cnt = await db.rawQuery('SELECT COUNT(*) as c FROM product_units_local');
  print('product_units_local rows: ' + cnt.first['c'].toString());

  final def = await db.rawQuery(
    'SELECT COUNT(*) as c FROM product_units_local WHERE is_default = 1');
  print('default units: ' + def.first['c'].toString());

  await db.close();
  print('DONE.');
}
