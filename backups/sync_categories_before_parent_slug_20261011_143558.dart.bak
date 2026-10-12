// tools/sync_categories.dart
// v8.3.8.1 - Sync categories tree from Hasura to local SQLite
// Pure Dart - no Flutter SDK needed
import 'dart:io';

import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Read .env manually (replacement for flutter_dotenv)
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
  print('=== sync_categories.dart v8.3.8.1 ===');

  sqfliteFfiInit();

  const envPath = 'D:/albaraka/albaraka_pos/.env';
  final env = loadEnvFile(envPath);
  final secret = env['HASURA_ADMIN_SECRET'] ?? '';

  if (secret.isEmpty) {
    print('ERROR: HASURA_ADMIN_SECRET not found in .env');
    print('Path checked: ' + envPath);
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
    print('WARNING: 0 categories returned. Check Hasura categories table.');
    exit(1);
  }

  const dbPath = 'D:/albaraka/data/albaraka_local.db';
  print('Opening SQLite: ' + dbPath);
  final db = await databaseFactoryFfi.openDatabase(dbPath);

  int inserted = 0;
  final syncedAt = DateTime.now().toUtc().toIso8601String();

  await db.transaction((txn) async {
    for (final c in cats) {
      await txn.insert(
        'categories_local',
        {
          'slug': c['slug'] as String,
          'name': c['name'] as String,
          'parent_id': c['parent_id'],
          'synced_at': syncedAt,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      inserted++;
    }
  });
  print('Upserted locally: ' + inserted.toString());

  final childrenRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local WHERE parent_id IS NOT NULL',
  );
  final rootsRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local WHERE parent_id IS NULL',
  );
  final totalRes = await db.rawQuery(
    'SELECT COUNT(*) AS c FROM categories_local',
  );

  print('--- Verification ---');
  print('Total in categories_local: ' + totalRes.first['c'].toString());
  print('Roots (parent_id IS NULL): ' + rootsRes.first['c'].toString());
  print('Children (parent_id NOT NULL): ' + childrenRes.first['c'].toString());

  await db.close();
  print('DONE');
}