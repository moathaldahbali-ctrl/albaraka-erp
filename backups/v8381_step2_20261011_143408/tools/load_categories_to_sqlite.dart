// load_categories_to_sqlite.dart
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
  print('Fetching categories...');

  final data = await gql(secret, r'''
    query {
      categories(order_by: {name: asc}) { slug name }
    }
  ''');

  final cats = (data['categories'] as List).cast<Map<String, dynamic>>();
  print('Fetched ' + cats.length.toString() + ' categories');

  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(
    r'D:\albaraka\data\albaraka_local.db');

  await db.transaction((txn) async {
    await txn.delete('categories_local');
    final b = txn.batch();
    final now = DateTime.now().toIso8601String();
    for (final c in cats) {
      b.insert('categories_local', {
        'slug': c['slug'],
        'name': c['name'],
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await b.commit(noResult: true);
  });

  final cnt = await db.rawQuery('SELECT COUNT(*) as c FROM categories_local');
  print('categories_local rows: ' + cnt.first['c'].toString());

  print('');
  print('Sample (used categories):');
  final used = await db.rawQuery('''
    SELECT p.category_slug AS slug, c.name AS name, COUNT(*) AS cnt
    FROM products_local p
    LEFT JOIN categories_local c ON c.slug = p.category_slug
    WHERE p.category_slug IS NOT NULL
    GROUP BY p.category_slug
    ORDER BY c.name ASC
    LIMIT 5
  ''');
  for (final r in used) { print('  ' + r.toString()); }

  await db.close();
  print('DONE.');
}
