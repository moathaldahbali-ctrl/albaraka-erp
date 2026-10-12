// extract_csv.dart
// Reads products_raw.csv, cleans it, applies category map, writes products_import.csv

import 'dart:io';
import 'dart:convert';

const Map<String, String> prefixMap = {
  '01': 'rice_pasta', '07': 'rice_pasta', '101': 'rice_pasta',
  '107': 'rice_pasta', '135': 'rice_pasta',
  '02': 'milk', '2': 'milk',
  '03': 'juices', '103': 'juices',
  '04': 'dairy', '104': 'dairy', '11': 'dairy',
  '111': 'dairy', '131': 'dairy',
  '05': 'biscuits', '105': 'biscuits', '08': 'biscuits',
  '06': 'pastries',
  '09': 'supplies', '109': 'supplies', '10': 'supplies',
  '110': 'supplies', '26': 'supplies', '27': 'supplies',
  '29': 'supplies', '33': 'supplies',
  '12': 'mineral_water', '112': 'mineral_water',
  '13': 'jam_butter',
  '14': 'oils_ghee_butter', '114': 'oils_ghee_butter',
  '15': 'canned', '115': 'canned', '32': 'canned', '132': 'canned',
  '16': 'vinegar_salt_sauce', '116': 'vinegar_salt_sauce',
  '17': 'scented_water',
  '18': 'soft_drinks', '118': 'soft_drinks',
  '19': 'honey',
  '20': 'cosmetics', '120': 'cosmetics', '142': 'cosmetics',
  '21': 'supplies',
  '22': 'detergents_soap', '122': 'detergents_soap',
  '23': 'chips', '123': 'chips',
  '24': 'sweets', '124': 'sweets', '126': 'sweets',
  '136': 'sweets', '28': 'sweets',
  '25': 'tools', '125': 'tools', '30': 'tools',
  '130': 'tools', '31': 'tools', '36': 'tools',
  '37': 'cake', '137': 'cake',
  '38': 'recharge_cards', '138': 'recharge_cards',
  '40': 'accessories', '140': 'accessories',
  '41': 'supplies',
  '88': 'fireworks', '188': 'fireworks',
};

const Map<String, String> skuOverride = {
  '35-124': 'sweets', '35-272': 'supplies', '35-331': 'rice_pasta',
  '35-419': 'supplies', '35-420': 'supplies', '35-421': 'supplies',
  '35-422': 'rice_pasta', '35-423': 'rice_pasta', '35-424': 'rice_pasta',
  '35-425': 'rice_pasta', '35-426': 'rice_pasta', '35-427': 'rice_pasta',
  '35-428': 'rice_pasta',
  '42-011': 'supplies', '42-029': 'sweets', '42-048': 'canned',
  '42-088': 'cosmetics', '42-104': 'cosmetics', '42-105': 'cosmetics',
  '42-120': 'cosmetics', '42-121': 'cosmetics', '42-177': 'cosmetics',
  '42-312': 'sweets', '42-433': 'supplies', '42-477': 'supplies',
  '42-626': 'supplies', '42-677': 'supplies', '42-679': 'sweets',
  '42-851': 'supplies', '42-904': 'supplies', '42-928': 'supplies',
  '42-938': 'supplies',
};

double cleanNum(String v) {
  if (v.isEmpty) return 0;
  v = v.replaceAll(',', '').trim();
  return double.tryParse(v) ?? 0;
}

String getCategory(String sku) {
  if (skuOverride.containsKey(sku)) return skuOverride[sku]!;
  final prefix = sku.split('-').first;
  return prefixMap[prefix] ?? 'supplies';
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

void main() {
  final src = File(r'D:\albaraka\data\products_raw.csv');
  final dst = File(r'D:\albaraka\data\products_import.csv');

  if (!src.existsSync()) {
    print('ERROR: file not found: ' + src.path);
    exit(1);
  }

  final content = src.readAsStringSync(encoding: utf8);
  final lines = const LineSplitter().convert(content);
  print('Raw rows: ' + lines.length.toString());

  final out = StringBuffer();
  out.writeln('sku,name,category_slug,unit,standard_cost,sale_price,stock_qty,barcode');

  int count = 0;
  int estimatedPrice = 0;
  final catCount = <String, int>{};

  for (int i = 1; i < lines.length; i++) {
    final f = splitCsv(lines[i]);
    if (f.length < 9) continue;

    final sku = f[1].trim();
    if (sku.isEmpty) continue;
    if (sku.toLowerCase() == 'null') continue;

    var name = f[2].trim().replaceAll('"', '');
    final unit = f[4].trim();
    final stockRaw = cleanNum(f[5]);
    final stock = stockRaw < 0 ? 0.0 : stockRaw;
    final cost = cleanNum(f[6]).abs();
    double price = cleanNum(f[7]);
    if (price == 0) {
      price = (cost * 1.30).roundToDouble();
      estimatedPrice++;
    }
    final barcode = f[8].trim();

    final cat = getCategory(sku);
    catCount[cat] = (catCount[cat] ?? 0) + 1;

    if (name.contains(',')) {
      name = '"' + name + '"';
    }
    out.writeln(sku + ',' + name + ',' + cat + ',' + unit + ',' +
                cost.toString() + ',' + price.toString() + ',' +
                stock.toString() + ',' + barcode);
    count++;
  }

  dst.writeAsStringSync(out.toString(), encoding: utf8);

  print('');
  print('Saved: ' + dst.path);
  print('Products: ' + count.toString());
  print('Estimated sale_price for ' + estimatedPrice.toString() + ' items (cost x 1.30)');
  print('');
  print('Category distribution:');
  final sorted = catCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  for (final e in sorted) {
    print('  ' + e.key + ': ' + e.value.toString());
  }
}
