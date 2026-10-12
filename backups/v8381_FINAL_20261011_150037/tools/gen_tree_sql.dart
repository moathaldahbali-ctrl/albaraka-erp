// tools/gen_tree_sql.dart
// v8.3.8.1 — توليد SQL للشجرة الهرمية
import 'dart:convert';
import 'dart:io';

void main() {
  final buf = StringBuffer();
  buf.writeln('-- v8.3.8.1: Hierarchical categories');
  buf.writeln('BEGIN;');
  buf.writeln('');
  buf.writeln('-- 1) Add parent_id column');
  buf.writeln('ALTER TABLE categories ADD COLUMN IF NOT EXISTS parent_id uuid REFERENCES categories(id) ON DELETE SET NULL;');
  buf.writeln('CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);');
  buf.writeln('');

  // 2) Insert parents as List<List<String>>
  buf.writeln('-- 2) Insert 6 parent categories');
  final parents = <List<String>>[
    ['10000000-0000-0000-0000-000000000001', 'basic_food', '\u0627\u0644\u0623\u063A\u0630\u064A\u0629 \u0627\u0644\u0623\u0633\u0627\u0633\u064A\u0629'],
    ['10000000-0000-0000-0000-000000000002', 'dairy_products', '\u0645\u0646\u062A\u062C\u0627\u062A \u0627\u0644\u0623\u0644\u0628\u0627\u0646'],
    ['10000000-0000-0000-0000-000000000003', 'beverages', '\u0627\u0644\u0645\u0634\u0631\u0648\u0628\u0627\u062A'],
    ['10000000-0000-0000-0000-000000000004', 'snacks', '\u0627\u0644\u0648\u062C\u0628\u0627\u062A \u0627\u0644\u062E\u0641\u064A\u0641\u0629'],
    ['10000000-0000-0000-0000-000000000005', 'care_cleaning', '\u0627\u0644\u0639\u0646\u0627\u064A\u0629 \u0648\u0627\u0644\u062A\u0646\u0638\u064A\u0641'],
    ['10000000-0000-0000-0000-000000000006', 'other', '\u0623\u062E\u0631\u0649'],
  ];
  for (final p in parents) {
    buf.writeln("INSERT INTO categories (id, slug, name, parent_id) VALUES ('" + p[0] + "', '" + p[1] + "', '" + p[2] + "', NULL) ON CONFLICT (slug) DO UPDATE SET name = EXCLUDED.name;");
  }
  buf.writeln('');

  // 3) Update children
  buf.writeln('-- 3) Link children to parents');
  final mappings = <String, List<String>>{
    '10000000-0000-0000-0000-000000000001': ['rice_pasta','oils_ghee_butter','pastries','canned','vegetables','minced_meat','vinegar_salt_sauce'],
    '10000000-0000-0000-0000-000000000002': ['milk','dairy','jam_butter'],
    '10000000-0000-0000-0000-000000000003': ['juices','mineral_water','scented_water','soft_drinks'],
    '10000000-0000-0000-0000-000000000004': ['biscuits','cake','honey','chips','sweets'],
    '10000000-0000-0000-0000-000000000005': ['accessories','cosmetics','detergents_soap'],
    '10000000-0000-0000-0000-000000000006': ['balance','foreigners','supplies','tools','qour','recharge_cards','fireworks'],
  };
  for (final entry in mappings.entries) {
    final slugs = entry.value.map((s) => "'" + s + "'").join(',');
    buf.writeln("UPDATE categories SET parent_id = '" + entry.key + "' WHERE slug IN (" + slugs + ");");
  }

  buf.writeln('COMMIT;');

  final outPath = r'D:\albaraka\tree_migration.sql';
  final file = File(outPath);
  file.writeAsStringSync(buf.toString(), encoding: utf8, flush: true);
  print('OK written: ' + outPath);
  print('Size: ' + file.lengthSync().toString() + ' bytes');
}