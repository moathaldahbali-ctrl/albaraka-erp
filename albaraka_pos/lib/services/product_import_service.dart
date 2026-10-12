import 'dart:io';
import 'package:excel/excel.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../models/product_import_row.dart';

class ImportResult {
  final int totalRows;
  final int validRows;
  final int invalidRows;
  final int imported;
  final List<ProductImportRow> rows;
  final List<String> createdProductIds;
  final String? fatalError;

  ImportResult({
    required this.totalRows,
    required this.validRows,
    required this.invalidRows,
    required this.imported,
    required this.rows,
    this.createdProductIds = const [],
    this.fatalError,
  });

  @override
  String toString() =>
      'ImportResult(total=' +
      totalRows.toString() +
      ', valid=' +
      validRows.toString() +
      ', invalid=' +
      invalidRows.toString() +
      ', imported=' +
      imported.toString() +
      ', fatal=' +
      (fatalError ?? 'null') +
      ', created=' +
      createdProductIds.length.toString() +
      ')';
}

class ProductImportService {
  final Database db;
  ProductImportService(this.db);

  static const _uuid = Uuid();

  Future<List<ProductImportRow>> parseExcel(String filePath) async {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) return [];
    final sheet = excel.tables[excel.tables.keys.first]!;
    if (sheet.maxRows < 2) return [];

    final headers = <String, int>{};
    final firstRow = sheet.row(0);
    for (int i = 0; i < firstRow.length; i++) {
      final c = firstRow[i];
      final txt = (c?.value?.toString() ?? '').trim().toLowerCase();
      if (txt.isNotEmpty) headers[txt] = i;
    }

    int? idxOf(List<String> keys) {
      for (final k in keys) {
        if (headers.containsKey(k)) return headers[k];
      }
      return null;
    }

    final iSku = idxOf(['sku', 'code']);
    final iName = idxOf(['name', 'product_name']);
    final iUnit = idxOf(['unit', 'unit_code']);
    final iCost = idxOf(['standard_cost', 'cost']);
    final iPrice = idxOf(['sale_price', 'price']);
    final iCat = idxOf(['category', 'category_slug']);

    final rows = <ProductImportRow>[];
    for (int r = 1; r < sheet.maxRows; r++) {
      final row = sheet.row(r);
      String cell(int? idx) {
        if (idx == null || idx >= row.length) return '';
        return (row[idx]?.value?.toString() ?? '').trim();
      }

      final sku = cell(iSku);
      final name = cell(iName);
      final unit = cell(iUnit);
      final costRaw = cell(iCost);
      final priceRaw = cell(iPrice);
      final cat = cell(iCat);
      if (sku.isEmpty && name.isEmpty) continue;

      final cost = _parseNum(costRaw);
      final price = _parseNum(priceRaw);
      final rowObj = ProductImportRow(
        rowNumber: r + 1,
        sku: sku,
        name: name,
        unitCode: unit.isEmpty ? null : unit,
        standardCost: cost ?? 0,
        salePrice: price ?? 0,
        categorySlug: cat.isEmpty ? null : cat,
      );
      if (sku.isEmpty) {
        rowObj.error = 'SKU missing';
      } else if (name.isEmpty) {
        rowObj.error = 'Name missing';
      } else if (cost == null) {
        rowObj.error = 'Bad cost: ' + costRaw;
      } else if (price == null) {
        rowObj.error = 'Bad price: ' + priceRaw;
      }
      rows.add(rowObj);
    }
    return rows;
  }

  static double? _parseNum(String s) {
    if (s.isEmpty) return null;
    final cleaned = s.replaceAll(',', '').replaceAll(' ', '');
    return double.tryParse(cleaned);
  }

  Future<List<String>> insertBatch(List<ProductImportRow> rows) async {
    final valid = rows.where((r) => r.isValid).toList();
    if (valid.isEmpty) return const [];
    final createdIds = <String>[];
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in valid) {
        final productId = _uuid.v4();
        createdIds.add(productId);
        batch.insert(
          'products_local',
          row.toProductsLocal(id: productId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        batch.insert(
          'product_units_local',
          row.toDefaultProductUnit(id: _uuid.v4(), productId: productId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    return createdIds;
  }

  Future<String> exportErrorsCsv(
      List<ProductImportRow> rows, String outputPath) async {
    final sb = StringBuffer();
    sb.writeln('row,sku,name,error');
    for (final r in rows.where((r) => !r.isValid)) {
      final sku = r.sku.replaceAll('"', '""');
      final name = r.name.replaceAll('"', '""');
      final err = (r.error ?? '').replaceAll('"', '""');
      sb.writeln('${r.rowNumber},"$sku","$name","$err"');
    }
    await File(outputPath).writeAsString(sb.toString());
    return outputPath;
  }

  Future<int> rollbackProducts(List<String> productIds) async {
    if (productIds.isEmpty) return 0;
    final ph = List.filled(productIds.length, '?').join(',');
    int deleted = 0;
    await db.transaction((txn) async {
      await txn.delete(
        'product_units_local',
        where: 'product_id IN ($ph)',
        whereArgs: productIds,
      );
      deleted = await txn.delete(
        'products_local',
        where: 'id IN ($ph)',
        whereArgs: productIds,
      );
    });
    return deleted;
  }

  Future<ImportResult> importFromFile(String filePath) async {
    try {
      final rows = await parseExcel(filePath);
      final valid = rows.where((r) => r.isValid).length;
      final invalid = rows.length - valid;
      final createdIds = await insertBatch(rows);
      return ImportResult(
        totalRows: rows.length,
        validRows: valid,
        invalidRows: invalid,
        imported: createdIds.length,
        rows: rows,
        createdProductIds: createdIds,
      );
    } catch (e) {
      return ImportResult(
        totalRows: 0,
        validRows: 0,
        invalidRows: 0,
        imported: 0,
        rows: const [],
        fatalError: e.toString(),
      );
    }
  }
}