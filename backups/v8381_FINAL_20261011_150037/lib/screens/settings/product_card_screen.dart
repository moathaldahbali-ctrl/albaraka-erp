import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../db/local_db.dart';
import '../../services/product_units_service.dart';
import '../../widgets/product_units_dialog.dart';

/// v8.3.7d — شاشة بطاقة الصنف المستقلة
class ProductCardScreen extends StatefulWidget {
  final String? initialProductId;

  const ProductCardScreen({super.key, this.initialProductId});

  @override
  State<ProductCardScreen> createState() => _ProductCardScreenState();
}

class _ProductCardScreenState extends State<ProductCardScreen> {
  bool _searchMode = true;

  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;

  Map<String, dynamic>? _product;
  List<Map<String, dynamic>> _units = [];
  List<Map<String, dynamic>> _barcodes = [];
  List<Map<String, dynamic>> _movements = [];
  bool _loadingCard = false;

  ProductUnitsService? _unitsService;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final db = await LocalDatabase.instance.database;
    _unitsService = ProductUnitsService(db);
    if (widget.initialProductId != null) {
      await _loadCard(widget.initialProductId!);
    } else {
      _searchFocus.requestFocus();
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _searching = true);

    final db = await LocalDatabase.instance.database;
    final barcodeRows = await db.query(
      'product_barcodes_local',
      where: 'barcode = ?',
      whereArgs: [q],
      limit: 1,
    );

    if (barcodeRows.isNotEmpty) {
      final productId = barcodeRows.first['product_id'] as String;
      if (!mounted) return;
      setState(() => _searching = false);
      await _loadCard(productId);
      return;
    }

    final rows = await LocalDatabase.instance.searchProductsFast(q, limit: 100);
    if (!mounted) return;
    setState(() {
      _searchResults = rows;
      _searching = false;
    });
  }

  Future<void> _loadCard(String productId) async {
    setState(() {
      _loadingCard = true;
      _searchMode = false;
    });

    final db = await LocalDatabase.instance.database;
    final pRows = await db.query(
      'products_local',
      where: 'id = ?',
      whereArgs: [productId],
      limit: 1,
    );

    if (pRows.isEmpty) {
      if (!mounted) return;
      setState(() {
        _loadingCard = false;
        _searchMode = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الصنف غير موجود محلياً')),
      );
      return;
    }

    final units = await _unitsService!.getUnits(productId);
    final barcodes = await _unitsService!.getBarcodes(productId);

    final movements = await db.rawQuery('''
      SELECT sl.product_name, sl.quantity, sl.unit_price, sl.subtotal,
             sl.unit_code, s.invoice_number, s.occurred_at
      FROM sale_lines_local sl
      JOIN sales_local s ON s.id = sl.sale_id
      WHERE sl.product_id = ?
      ORDER BY s.occurred_at DESC
      LIMIT 20
    ''', [productId]);

    if (!mounted) return;
    setState(() {
      _product = pRows.first;
      _units = units;
      _barcodes = barcodes;
      _movements = movements;
      _loadingCard = false;
    });
  }

  void _backToSearch() {
    setState(() {
      _searchMode = true;
      _product = null;
      _units = [];
      _barcodes = [];
      _movements = [];
      _searchCtrl.clear();
      _searchResults = [];
    });
    _searchFocus.requestFocus();
  }

  Future<void> _openUnitsDialog() async {
    if (_product == null) return;
    await showDialog(
      context: context,
      builder: (_) => ProductUnitsDialog(
        productId: _product!['id'] as String,
        productName: (_product!['name'] as String?) ?? '',
      ),
    );
    if (!mounted) return;
    await _loadCard(_product!['id'] as String);
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  String _fmtDate(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('MM/dd HH:mm').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_searchMode ? 'بطاقة الصنف — بحث' : 'بطاقة الصنف'),
          actions: [
            if (!_searchMode)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'بحث جديد',
                onPressed: _backToSearch,
              ),
          ],
        ),
        body: _searchMode ? _buildSearchView(theme) : _buildCardView(theme),
      ),
    );
  }

  Widget _buildSearchView(ThemeData theme) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
            onSubmitted: (_) => _runSearch(),
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم، SKU، أو امسح الباركود',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        if (_searching)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child: _searchResults.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.qr_code_scanner,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('ابحث بالاسم أو امسح باركود',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (ctx, i) {
                    final p = _searchResults[i];
                    return ListTile(
                      dense: true,
                      leading: Text(
                        (p['sku'] as String?) ?? '-',
                        style: const TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey),
                      ),
                      title: Text((p['name'] as String?) ?? '-',
                          style: const TextStyle(fontSize: 13)),
                      subtitle: Text((p['category_slug'] as String?) ?? '',
                          style: const TextStyle(fontSize: 11)),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 14, color: theme.colorScheme.primary),
                      onTap: () => _loadCard(p['id'] as String),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCardView(ThemeData theme) {
    if (_loadingCard) return const Center(child: CircularProgressIndicator());
    final p = _product;
    if (p == null) return const SizedBox();

    final qty = (p['stock_qty'] as num?)?.toDouble() ?? 0;
    final cost = (p['standard_cost'] as num?)?.toDouble() ?? 0;
    final price = (p['sale_price'] as num?)?.toDouble() ?? 0;
    final value = qty * cost;
    final margin = price - cost;
    final marginPct = cost > 0 ? (margin / cost * 100) : 0;
    final color = qty <= 0
        ? Colors.red
        : qty < 10
            ? Colors.orange
            : Colors.green;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((p['name'] as String?) ?? '-',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('SKU: ${(p['sku'] as String?) ?? '-'}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: Colors.grey)),
                          ],
                        ),
                      ),
                      Chip(
                        label: Text(
                          qty <= 0
                              ? 'نفد'
                              : qty < 10
                                  ? 'منخفض'
                                  : 'متوفر',
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      _kv('التصنيف', (p['category_slug'] as String?) ?? '-'),
                      _kv('الوحدة الأساسية',
                          (p['unit_id'] as String?) ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _kvNum('الرصيد', qty, color),
                      _kvNum('التكلفة', cost, null),
                      _kvNum('سعر البيع', price, null),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _kvNum('قيمة المخزون', value, null),
                      _kvNum('هامش الربح', margin,
                          margin > 0 ? Colors.green : Colors.red),
                      _kvNum('نسبة الهامش %', marginPct, null),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _sectionHeader(
            '📦 وحدات الصنف (${_units.length})',
            onAction: _openUnitsDialog,
            actionLabel: 'إدارة',
            actionIcon: Icons.edit,
          ),
          const SizedBox(height: 8),
          if (_units.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('لا توجد وحدات — اضغط "إدارة" لإضافة',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Card(
              child: Column(
                children: _units.map((u) {
                  final isDefault = (u['is_default'] as int? ?? 0) == 1;
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      isDefault ? Icons.star : Icons.straighten,
                      color: isDefault ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    title: Text(u['unit_code'] as String? ?? '-',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        'معامل: ${(u['conversion_factor'] as num?)?.toStringAsFixed(2) ?? '-'}',
                        style: const TextStyle(fontSize: 11)),
                    trailing: isDefault
                        ? const Text('★ افتراضية',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold))
                        : null,
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          _sectionHeader(
            '📷 الباركود (${_barcodes.length})',
            onAction: _openUnitsDialog,
            actionLabel: 'إضافة',
            actionIcon: Icons.add,
          ),
          const SizedBox(height: 8),
          if (_barcodes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('لا توجد باركودات',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Card(
              child: Column(
                children: _barcodes.map((b) {
                  final unitId = b['product_unit_id'] as String?;
                  final unitLabel = unitId == null
                      ? 'المنتج الأساسي'
                      : _units.firstWhere(
                          (u) => u['id'] == unitId,
                          orElse: () => {'unit_code': '؟'},
                        )['unit_code'] as String;
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.qr_code,
                        size: 20, color: Colors.blueGrey),
                    title: Text(b['barcode'] as String? ?? '-',
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 13)),
                    subtitle: Text(unitLabel,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey)),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 16),

          Text('📊 آخر حركات هذا الصنف (${_movements.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_movements.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('لا توجد حركات مسجّلة',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Card(
              child: Column(
                children: _movements.map((m) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.receipt_long, size: 18),
                    title: Text(
                      '${(m['invoice_number'] as String?) ?? '-'} · ${_fmtDate(m['occurred_at'] as String?)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      '${_fmtNum((m['quantity'] as num?) ?? 0)} × ${_fmtNum((m['unit_price'] as num?) ?? 0)} · ${(m['unit_code'] as String?) ?? ''}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: Text(_fmtNum((m['subtotal'] as num?) ?? 0),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title,
      {required VoidCallback onAction,
      required String actionLabel,
      required IconData actionIcon}) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        FilledButton.icon(
          onPressed: onAction,
          icon: Icon(actionIcon, size: 16),
          label: Text(actionLabel),
          style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
        ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(v,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _kvNum(String k, num v, Color? color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(_fmtNum(v),
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}