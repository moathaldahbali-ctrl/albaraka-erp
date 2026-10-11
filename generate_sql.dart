// generate_sql.dart
// Reads products_import.csv, generates SQL batch files with ON CONFLICT DO NOTHING

import 'dart:io';
import 'dart:convert';
import 'dart:math';

const String BRANCH_ID = '11111111-1111-1111-1111-111111111111';
const String WAREHOUSE_ID = '33333333-3333-3333-3333-333333333333';
const int BATCH_SIZE = 200;

class Product {
  final String sku, name, category, unit;
  final double cost, price, stock;
  Product(this.sku, this.name, this.category, this.unit,
          this.cost, this.price, this.stock);
}

List<String> splitCsv(String line) {
  final result = <String>[];
  final buf = StringBuffer();
  bool inQ = false;
  for (int i = 0; i < line.length; i++) {
    final c = line[i];
    if (c == '"') {
      inQ = !inQ;
    } else if (c == ',' && !inQ) {
      result.add(buf.toString());
      buf.clear();
    } else {
      buf.write(c);
    }
  }
  result.add(buf.toString());
  return result;
}

String esc(String s) => s.replaceAll("'", "''");

String num(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toString();
}

void main() {
  final src = File(r'D:\albaraka\data\products_import.csv');
  final outDir = Directory(r'D:\albaraka\data\sql_batches');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  if (!src.existsSync()) {
    print('ERROR: not found: ' + src.path);
    exit(1);
  }

  final content = src.readAsStringSync(encoding: utf8);
  final lines = const LineSplitter().convert(content);

  final products = <Product>[];
  for (int i = 1; i < lines.length; i++) {
    if (lines[i].trim().isEmpty) continue;
    final f = splitCsv(lines[i]);
    if (f.length < 7) continue;
    products.add(Product(
      f[0].trim(), f[1].trim(), f[2].trim(), f[3].trim(),
      double.tryParse(f[4]) ?? 0,
      double.tryParse(f[5]) ?? 0,
      double.tryParse(f[6]) ?? 0,
    ));
  }

  print('Loaded ' + products.length.toString() + ' products');

  final total = products.length;
  final batches = (total / BATCH_SIZE).ceil();
  print('Generating ' + batches.toString() + ' batches of ' + BATCH_SIZE.toString());

  for (int b = 0; b < batches; b++) {
    final start = b * BATCH_SIZE;
    final end = min(start + BATCH_SIZE, total);
    final batch = products.sublist(start, end);

    final buf = StringBuffer();
    buf.writeln('-- Batch ' + (b + 1).toString() + '/' + batches.toString() +
                '  (' + batch.length.toString() + ' products, rows ' +
                (start + 1).toString() + '-' + end.toString() + ')');
    buf.writeln('');

    // (1) products
    buf.writeln('-- (1) products');
    buf.writeln('INSERT INTO products (category_id, sku, name, standard_cost, sale_price)');
    buf.writeln('SELECT c.id, v.sku, v.name, v.cost, v.price');
    buf.writeln('FROM (VALUES');
    for (int i = 0; i < batch.length; i++) {
      final p = batch[i];
      final c = i < batch.length - 1 ? ',' : '';
      buf.writeln("  ('" + esc(p.category) + "', '" + esc(p.sku) + "', '" +
                  esc(p.name) + "', " + num(p.cost) + "::numeric, " +
                  num(p.price) + "::numeric)" + c);
    }
    buf.writeln(') AS v(slug, sku, name, cost, price)');
    buf.writeln('JOIN categories c ON c.slug = v.slug');
    buf.writeln('ON CONFLICT (sku) DO NOTHING;');
    buf.writeln('');

    // (2) product_units
    buf.writeln('-- (2) product_units');
    buf.writeln('INSERT INTO product_units (product_id, unit_code, conversion_factor)');
    buf.writeln('SELECT p.id, v.unit, 1');
    buf.writeln('FROM (VALUES');
    for (int i = 0; i < batch.length; i++) {
      final p = batch[i];
      final c = i < batch.length - 1 ? ',' : '';
      buf.writeln("  ('" + esc(p.sku) + "', '" + esc(p.unit) + "')" + c);
    }
    buf.writeln(') AS v(sku, unit)');
    buf.writeln('JOIN products p ON p.sku = v.sku');
    buf.writeln('ON CONFLICT (product_id, unit_code) DO NOTHING;');
    buf.writeln('');

    // (3) branch_products
    buf.writeln('-- (3) branch_products');
    buf.writeln('INSERT INTO branch_products (branch_id, product_id, status)');
    buf.writeln("SELECT '" + BRANCH_ID + "'::uuid, p.id, 'active'");
    buf.writeln('FROM products p');
    buf.write('WHERE p.sku IN (');
    for (int i = 0; i < batch.length; i++) {
      if (i > 0) buf.write(', ');
      buf.write("'" + esc(batch[i].sku) + "'");
    }
    buf.writeln(')');
    buf.writeln('ON CONFLICT (branch_id, product_id) DO NOTHING;');
    buf.writeln('');

    // (4) stock_balances
    buf.writeln('-- (4) stock_balances');
    buf.writeln('INSERT INTO stock_balances (warehouse_id, product_id, quantity)');
    buf.writeln("SELECT '" + WAREHOUSE_ID + "'::uuid, p.id, v.qty");
    buf.writeln('FROM (VALUES');
    for (int i = 0; i < batch.length; i++) {
      final p = batch[i];
      final c = i < batch.length - 1 ? ',' : '';
      buf.writeln("  ('" + esc(p.sku) + "', " + num(p.stock) + "::numeric)" + c);
    }
    buf.writeln(') AS v(sku, qty)');
    buf.writeln('JOIN products p ON p.sku = v.sku');
    buf.writeln('ON CONFLICT (warehouse_id, product_id) DO NOTHING;');

    final outFile = File(outDir.path + '\\import_batch_' + (b + 1).toString() + '.sql');
    outFile.writeAsStringSync(buf.toString(), encoding: utf8);
    print('  batch ' + (b + 1).toString() + ': ' +
          batch.length.toString() + ' products -> ' + outFile.path);
  }

  print('');
  print('Done. ' + batches.toString() + ' files in: ' + outDir.path);
}
