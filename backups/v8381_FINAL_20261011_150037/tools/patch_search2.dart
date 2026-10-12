import 'dart:io';
void main() {
  final f = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var c = f.readAsStringSync();
  
  final oldBlock = "        whereParts.add('(name LIKE ? OR sku LIKE ?)');\n        final q = '%' + w + '%';\n        args.add(q);\n        args.add(q);";
  
  final newBlock = "        final variants = _arabicVariants(w);\n        final variantParts = <String>[];\n        for (final v in variants) {\n          variantParts.add('(name LIKE ? OR sku LIKE ?)');\n          final q = '%' + v + '%';\n          args.add(q);\n          args.add(q);\n        }\n        whereParts.add('(' + variantParts.join(' OR ') + ')');";
  
  if (!c.contains('final variants = _arabicVariants')) {
    if (c.contains(oldBlock)) {
      c = c.replaceAll(oldBlock, newBlock);
      f.writeAsStringSync(c);
      print('OK patched');
    } else {
      print('ERROR: old block not found');
    }
  } else {
    print('SKIP: already patched');
  }
}