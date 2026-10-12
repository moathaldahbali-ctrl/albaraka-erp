import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../db/local_db.dart';
import '../../models/product_import_row.dart';
import '../../services/product_import_service.dart';

class ProductImportScreen extends StatefulWidget {
  const ProductImportScreen({super.key});
  @override
  State<ProductImportScreen> createState() => _ProductImportScreenState();
}

class _ProductImportScreenState extends State<ProductImportScreen> {
  String? _filePath;
  List<ProductImportRow> _rows = [];
  ImportResult? _result;
  bool _loading = false;
  bool _importing = false;
  List<String> _lastImportedIds = [];

  int get _validCount => _rows.where((r) => r.isValid).length;
  int get _invalidCount => _rows.length - _validCount;

  Future<void> _pickFile() async {
    final picks = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    if (picks.isEmpty) return;
    final path = picks.first.path;
    if (path == null) return;
    setState(() {
      _filePath = path;
      _loading = true;
      _rows = [];
      _result = null;
    });
    try {
      final db = await LocalDatabase.instance.database;
      final svc = ProductImportService(db);
      final rows = await svc.parseExcel(path);
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parse error: ' + e.toString())),
      );
    }
  }

  Future<void> _exportErrors() async {
    try {
      final outPath = 'D:\\albaraka\\data\\import_errors_'
          + DateTime.now().millisecondsSinceEpoch.toString() + '.csv';
      final db = await LocalDatabase.instance.database;
      final svc = ProductImportService(db);
      final path = await svc.exportErrorsCsv(_rows, outPath);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errors saved: ' + path)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: ' + e.toString())),
      );
    }
  }

  Future<void> _rollback() async {
    if (_lastImportedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rollback?'),
        content: Text('Delete ' + _lastImportedIds.length.toString()
          + ' recently imported products?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final db = await LocalDatabase.instance.database;
      final svc = ProductImportService(db);
      final deleted = await svc.rollbackProducts(_lastImportedIds);
      if (!mounted) return;
      setState(() {
        _lastImportedIds = [];
        _result = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rollback done: ' + deleted.toString() + ' products deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rollback error: ' + e.toString())),
      );
    }
  }

  Future<void> _import() async {
    if (_filePath == null) return;
    setState(() => _importing = true);
    try {
      final db = await LocalDatabase.instance.database;
      final svc = ProductImportService(db);
      final r = await svc.importFromFile(_filePath!);
      if (!mounted) return;
      setState(() {
        _result = r;
        _lastImportedIds = r.createdProductIds;
        _importing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported: ' + r.imported.toString())),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import error: ' + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Products from Excel'),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _loading ? null : _pickFile,
                  icon: const Icon(Icons.file_open),
                  label: const Text('Choose Excel File'),
                ),
                const SizedBox(width: 12),
                if (_filePath != null)
                  Expanded(
                    child: Text(
                      _filePath!.split(Platform.pathSeparator).last,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (!_loading && _rows.isNotEmpty) ...[
              Row(
                children: [
                  Chip(label: Text('Total: ' + _rows.length.toString())),
                  const SizedBox(width: 8),
                  Chip(
                    backgroundColor: Colors.green.shade100,
                    label: Text('Valid: ' + _validCount.toString()),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    backgroundColor: _invalidCount > 0
                      ? Colors.red.shade100
                      : Colors.grey.shade200,
                    label: Text('Invalid: ' + _invalidCount.toString()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('SKU')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Unit')),
                        DataColumn(label: Text('Cost')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: _rows.take(50).map((r) {
                        return DataRow(cells: [
                          DataCell(Text(r.rowNumber.toString())),
                          DataCell(Text(r.sku)),
                          DataCell(Text(r.name)),
                          DataCell(Text(r.effectiveUnitCode)),
                          DataCell(Text(r.standardCost.toString())),
                          DataCell(Text(r.salePrice.toString())),
                          DataCell(Text(r.effectiveCategorySlug)),
                          DataCell(Text(
                            r.isValid ? 'OK' : (r.error ?? '?'),
                            style: TextStyle(
                              color: r.isValid ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_rows.length > 50)
                Text('Showing first 50 of ' + _rows.length.toString() + ' rows',
                  style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: (_invalidCount <= 5 && !_importing) ? _import : null,
                icon: _importing
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.upload),
                label: Text(_importing ? 'Importing...' : 'Import Valid Rows'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _invalidCount > 0 ? _exportErrors : null,
                      icon: const Icon(Icons.download),
                      label: const Text('Export Errors (CSV)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _lastImportedIds.isNotEmpty ? _rollback : null,
                      icon: const Icon(Icons.undo),
                      label: Text('Rollback Last Import ('
                        + _lastImportedIds.length.toString() + ')'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    ),
                  ),
                ],
              ),
              if (_invalidCount > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Too many invalid rows (' + _invalidCount.toString() + '). Fix the Excel file first.',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 12),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Imported: ' + _result!.imported.toString() +
                    '\nValid: ' + _result!.validRows.toString() +
                    '\nInvalid: ' + _result!.invalidRows.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

