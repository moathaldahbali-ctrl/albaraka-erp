// tools/patch_v20.dart
// v8.3.8.1 — Migration v20: parent_id in categories_local
import 'dart:io';

void main() {
  final f = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var c = f.readAsStringSync();

  // 1) version: 19 → 20
  c = c.replaceFirst('      version: 19,', '      version: 21,');

  // 2) Add in onCreate: parent_id migration
  const oldCreate = "        await _createCategoriesTable(db);\n        await _createProductsTable(db);";
  const newCreate = "        await _createCategoriesTable(db);\n        await _addColumnIfMissing(db, 'categories_local', 'parent_id', 'TEXT');\n        await _createProductsTable(db);";
  if (c.contains(oldCreate)) {
    c = c.replaceFirst(oldCreate, newCreate);
    print('[1/2] onCreate updated');
  } else {
    print('[1/2] WARN: onCreate anchor not found');
  }

  // 3) Add onUpgrade v19 → v20
  const oldUpgrade = "        if (oldVersion < 19) {\n          await _createProductBarcodesTable(db);\n          debugPrint('[DB] v18 -> v19: product_barcodes_local created');\n        }";
  const newUpgrade = "        if (oldVersion < 19) {\n          await _createProductBarcodesTable(db);\n          debugPrint('[DB] v18 -> v19: product_barcodes_local created');\n        }\n        if (oldVersion < 20) {\n          await _addColumnIfMissing(db, 'categories_local', 'parent_id', 'TEXT');\n          debugPrint('[DB] v19 -> v20: categories_local.parent_id added');\n        }";
  
  if (c.contains(oldUpgrade)) {
    c = c.replaceFirst(oldUpgrade, newUpgrade);
    print('[2/2] onUpgrade updated');
  } else {
    print('[2/2] WARN: onUpgrade anchor not found (may have different formatting)');
  }

  f.writeAsStringSync(c);
  print('OK saved');
}