import 'package:flutter/material.dart';
import '../db/local_db.dart';
import '../services/product_units_service.dart';

/// v8.3.7b — Dialog إدارة وحدات الصنف + الباركود
class ProductUnitsDialog extends StatefulWidget {
  final String productId;
  final String productName;

  const ProductUnitsDialog({
    super.key,
    required this.productId,
    required this.productName,
  });

  @override
  State<ProductUnitsDialog> createState() => _ProductUnitsDialogState();
}

class _ProductUnitsDialogState extends State<ProductUnitsDialog> {
  ProductUnitsService? _service;
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _barcodes = [];
  bool _loading = true;
  String? _selectedUnitId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final db = await LocalDatabase.instance.database;
    _service = ProductUnitsService(db);
    await _reload();
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final svc = _service!;
    final units = await svc.getUnits(widget.productId);
    final barcodes = await svc.getBarcodes(widget.productId);
    if (!mounted) return;
    setState(() {
      _units = units;
      _barcodes = barcodes;
      _loading = false;
      if (_selectedUnitId != null &&
          !units.any((u) => u['id'] == _selectedUnitId)) {
        _selectedUnitId = null;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // العمليات
  // ═══════════════════════════════════════════════════════════

  Future<void> _showAddEditUnitDialog({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final codeCtrl = TextEditingController(
        text: isEdit ? (existing['unit_code'] as String? ?? '') : '');
    final factorCtrl = TextEditingController(
        text: isEdit
            ? ((existing['conversion_factor'] as num?)?.toString() ?? '1')
            : '1');
    bool isDefault = isEdit ? (existing['is_default'] as int? ?? 0) == 1 : false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(isEdit ? 'تعديل وحدة' : 'إضافة وحدة'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم الوحدة',
                    hintText: 'مثال: كرتون، شدة، باكت',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: factorCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'معامل التحويل',
                    hintText: 'مثال: 48 (كرتون = 48 فردة)',
                  ),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (v) => setDlgState(() => isDefault = v ?? false),
                  title: const Text('الوحدة الافتراضية'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );

    if (result != true) return;

    final code = codeCtrl.text.trim();
    final factor = double.tryParse(factorCtrl.text.trim());
    if (code.isEmpty || factor == null || factor <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الوحدة ومعامل صحيح')),
      );
      return;
    }

    final svc = _service!;
    if (isEdit) {
      await svc.updateUnit(
        existing['id'] as String,
        unitCode: code,
        conversionFactor: factor,
      );
      if (isDefault && (existing['is_default'] as int? ?? 0) == 0) {
        await svc.setDefaultUnit(widget.productId, existing['id'] as String);
      }
    } else {
      await svc.addUnit(
        productId: widget.productId,
        unitCode: code,
        conversionFactor: factor,
        isDefault: isDefault,
      );
    }
    await _reload();
  }

  Future<void> _deleteUnit(Map<String, dynamic> unit) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('حذف الوحدة "${unit['unit_code']}"؟'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;
    await _service!.deleteUnit(unit['id'] as String);
    await _reload();
  }

  Future<void> _showAddBarcodeDialog() async {
    final barcodeCtrl = TextEditingController();
    String? selectedUnitId = _selectedUnitId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('إضافة باركود'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: barcodeCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'الباركود',
                    hintText: 'امسح أو أدخل الباركود',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: selectedUnitId,
                  decoration: const InputDecoration(labelText: 'مرتبط بـ'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('المنتج الأساسي'),
                    ),
                    ..._units.map((u) => DropdownMenuItem<String?>(
                          value: u['id'] as String,
                          child: Text(u['unit_code'] as String? ?? ''),
                        )),
                  ],
                  onChanged: (v) => setDlgState(() => selectedUnitId = v),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('إلغاء')),
              FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('حفظ')),
            ],
          ),
        ),
      ),
    );

    if (result != true) return;
    final barcode = barcodeCtrl.text.trim();
    if (barcode.isEmpty) return;

    final svc = _service!;
    if (await svc.isBarcodeTaken(barcode)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا الباركود مستخدم بالفعل')),
      );
      return;
    }
    await svc.addBarcode(
      productId: widget.productId,
      productUnitId: selectedUnitId,
      barcode: barcode,
    );
    await _reload();
  }

  Future<void> _deleteBarcode(String barcodeId) async {
    await _service!.deleteBarcode(barcodeId);
    await _reload();
  }

  // ═══════════════════════════════════════════════════════════
  // الواجهة
  // ═══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 700,
          height: 600,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('إدارة وحدات الصنف',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(widget.productName,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Body
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader('الوحدات', Icons.straighten,
                                onAdd: () => _showAddEditUnitDialog()),
                            const SizedBox(height: 8),
                            _unitsTable(),
                            const SizedBox(height: 24),
                            _sectionHeader('الباركود', Icons.qr_code,
                                onAdd: _units.isEmpty
                                    ? null
                                    : _showAddBarcodeDialog),
                            const SizedBox(height: 8),
                            _barcodesList(),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon,
      {VoidCallback? onAdd}) {
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const Spacer(),
        if (onAdd != null)
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('إضافة'),
            style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
          ),
      ],
    );
  }

  Widget _unitsTable() {
    if (_units.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
            child: Text('لا توجد وحدات بعد',
                style: TextStyle(color: Colors.grey))),
      );
    }
    return Card(
      child: DataTable(
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 40,
        columnSpacing: 12,
        horizontalMargin: 8,
        columns: const [
          DataColumn(label: Text('#', style: TextStyle(fontSize: 11))),
          DataColumn(label: Text('الوحدة', style: TextStyle(fontSize: 11))),
          DataColumn(
              label: Text('العبوة', style: TextStyle(fontSize: 11)),
              numeric: true),
          DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 11))),
          DataColumn(label: Text('عمليات', style: TextStyle(fontSize: 11))),
        ],
        rows: _units.asMap().entries.map((e) {
          final i = e.key;
          final u = e.value;
          final isDefault = (u['is_default'] as int? ?? 0) == 1;
          return DataRow(cells: [
            DataCell(Text('${i + 1}',
                style: const TextStyle(fontSize: 11))),
            DataCell(Text(u['unit_code'] as String? ?? '-',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold))),
            DataCell(Text(
                (u['conversion_factor'] as num?)?.toStringAsFixed(2) ?? '-',
                style: const TextStyle(fontSize: 11))),
            DataCell(isDefault
                ? const Text('★ افتراضية',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.bold))
                : const Text('')),
            DataCell(Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  tooltip: 'تعديل',
                  onPressed: () => _showAddEditUnitDialog(existing: u),
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  tooltip: 'حذف',
                  onPressed: () => _deleteUnit(u),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _barcodesList() {
    if (_barcodes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
            child: Text('لا توجد باركودات',
                style: TextStyle(color: Colors.grey))),
      );
    }
    return Card(
      child: Column(
        children: _barcodes.map((b) {
          final unitId = b['product_unit_id'] as String?;
          final unitLabel = unitId == null
              ? 'المنتج الأساسي'
              : _units.firstWhere((u) => u['id'] == unitId,
                  orElse: () => {'unit_code': '؟'})['unit_code'] as String;
          return ListTile(
            dense: true,
            leading: const Icon(Icons.qr_code, size: 18),
            title: Text(b['barcode'] as String? ?? '-',
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 13)),
            subtitle: Text(unitLabel,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              onPressed: () => _deleteBarcode(b['id'] as String),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}