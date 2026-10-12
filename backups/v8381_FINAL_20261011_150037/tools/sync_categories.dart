// tools/sync_categories.dart
// v8.3.8.1 - Sync categories tree from Hasura to local SQLite
// Pure Dart - no Flutter SDK needed
import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Map<String, String> loadEnvFile(String path) {
  final env = <String, String>{};
  final file = File(path);
  if (!file.existsSync()) {
    print('ERROR: .env not found at: ' + path);
    return env;
  }
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    var value = trimmed.substring(idx + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    env[key] = value;
  }
  return env;
}

Future<void> main() async {
  print('=== sync_categories.dart v8.3.8.1 (parent_slug) ===');

  sqfliteFfiInit();

  const envPath = 'D:/albaraka/albaraka_pos/.env';
  final env = loadEnvFile(envPath);
  final secret = env['HASURA_ADMIN_SECRET'] ?? '';

  if (secret.isEmpty) {
    print('ERROR: HASURA_ADMIN_SECRET not found in .env');
    exit(1);
  }
  print('Admin secret loaded: ' + secret.length.toString() + ' chars');

  final client = GraphQLClient(
    link: HttpLink(
      'https://eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run/v1/graphql',
      defaultHeaders: {'x-hasura-admin-secret': secret},
    ),
    cache: GraphQLCache(),
  );

  const q = r'''
    query GetCategories {
      categories(order_by: {name: asc}) {
        id
        slug
        name
        parent_id
      }
    }
  ''';

  print('Querying Hasura...');
  final result = await client.query(QueryOptions(document: gql(q)));

  if (result.hasException) {
    print('ERROR GraphQL: ' + result.exception.toString());
    exit(1);
  }

  final cats = result.data!['categories'] as List;
  print('Fetched from Hasura: ' + cats.length.toString());

  if (cats.isEmpty) {
    print('WARNING: 0 categories returned.');
    exit(1);
  }

  // Build id -> slug map (for parent_slug resolution)
  final idToSlug = <String, String>{};
  for (final c in cats) {
    idToSlug[c['id'] as String] = c['slug'] as String;
  }
  print('ID->Slug map size: ' + idToSlug.length.toString());

  const dbPath = 'D:/albaraka/data/albaraka_local.db';
  print('Opening SQLite: ' + dbPath);
  final db = await databaseFactoryFfi.openDatabase(dbPath);

  int inserted = 0;
  int withParent = 0;
  final syncedAt = DateTime.now().toUtc().toIso8601String();

  await db.transaction((txn) async {
    for (final c in cats) {
      final parentId = c['parent_id'] as String?;
      final parentSlug = parentId != null ? idToSlug[parentId] : null;
      if (parentSlug != null) withParent++;

      await txn.insert(
        'categories_local',
        {
          'slug': c['slug'] as String,
          'name': c['name'] as String,
          'parent_id': parentId,
          'parent_slug': parentSlug,
          'synced_at': syncedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      inserted++;
    }
  });
  print('Upserted locally: ' + inserted.toString());
  print('With parent_slug: ' + withParent.toString());

  final totalRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local',
  );
  final rootsRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local WHERE parent_slug IS NULL',
  );
  final childrenRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local WHERE parent_slug IS NOT NULL',
  );

  print('--- Verification ---');
  print('Total: ' + totalRes.first['c'].toString());
  print('Roots (parent_slug IS NULL): ' + rootsRes.first['c'].toString());
  print('Children (parent_slug NOT NULL): ' + childrenRes.first['c'].toString());

  // Show tree preview
  print('--- Tree Preview ---');
  final roots = await db.rawQuery(
    'SELECT slug, name FROM categories_local WHERE parent_slug IS NULL ORDER BY name',
  );
  for (final r in roots) {
    print('* ' + r['name'].toString() + ' (' + r['slug'].toString() + ')');
    final kids = await db.rawQuery(
      'SELECT name FROM categories_local WHERE parent_slug = ? ORDER BY name',
      [r['slug']],
    );
    for (final k in kids) {
      print('    - ' + k['name'].toString());
    }
  }

  await db.close();
  print('DONE');
}