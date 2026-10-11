// migrate_v7.dart
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  final dbPath = r'D:\albaraka\data\albaraka_local.db';
  if (!File(dbPath).existsSync()) { print('DB not found'); exit(1); }

  final probe = await factory.openDatabase(dbPath);
  final v = await probe.rawQuery('PRAGMA user_version');
  final cur = v.first['user_version'] as int;
  print('Current version: ' + cur.toString());
  await probe.close();

  if (cur >= 7) { print('Already v7+. Nothing to do.'); return; }

  final db = await factory.openDatabase(
    dbPath,
    options: OpenDatabaseOptions(
      version: 7,
      onUpgrade: (d, oldV, newV) async {
        print('Upgrading from ' + oldV.toString() + ' to ' + newV.toString());
        if (oldV < 7) {
          print('  Creating product_units_local...');
          await d.execute('''
            CREATE TABLE IF NOT EXISTS product_units_local (
              id TEXT PRIMARY KEY,
              product_id TEXT NOT NULL,
              unit_code TEXT NOT NULL,
              conversion_factor REAL NOT NULL,
              is_default INTEGER NOT NULL DEFAULT 0,
              synced_at TEXT NOT NULL
            )
          ''');
          await d.execute('CREATE INDEX IF NOT EXISTS idx_pu_product ON product_units_local(product_id)');
          await d.execute('CREATE INDEX IF NOT EXISTS idx_pu_default ON product_units_local(product_id, is_default)');
          print('  Adding columns to sale_lines_local...');
          await d.execute('ALTER TABLE sale_lines_local ADD COLUMN product_unit_id TEXT');
          await d.execute('ALTER TABLE sale_lines_local ADD COLUMN unit_code TEXT');
          await d.execute('ALTER TABLE sale_lines_local ADD COLUMN conversion_factor REAL');
          print('  Adding payment_method + customer_name to sales_local...');
          await d.execute("ALTER TABLE sales_local ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'cash'");
          await d.execute('ALTER TABLE sales_local ADD COLUMN customer_name TEXT');
        }
      },
    ),
  );

  print('');
  print('=== After upgrade ===');
  final v2 = await db.rawQuery('PRAGMA user_version');
  print('user_version = ' + v2.first['user_version'].toString());

  print('sale_lines_local columns:');
  final cols = await db.rawQuery('PRAGMA table_info(sale_lines_local)');
  for (final c in cols) { print('  ' + c['name'].toString()); }

  print('sales_local columns:');
  final scols = await db.rawQuery('PRAGMA table_info(sales_local)');
  for (final c in scols) { print('  ' + c['name'].toString()); }

  await db.close();
  print('DONE.');
}
