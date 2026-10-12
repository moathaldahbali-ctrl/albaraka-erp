import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../db/local_db.dart';
import '../services/receipt_service.dart';

class InvoiceItem {
  final String productId;
  final String sku;
  final String productName;
  final double basePrice;
  final double? baseStockQty;
  final List<Map<String, dynamic>> availableUnits;
  String productUnitId;
  String unitCode;
  double conversionFactor;
  double quantity;
  final TextEditingController qtyCtrl;

  InvoiceItem({
    required this.productId,
    required this.sku,
    required this.productName,
    required this.basePrice,
    required this.baseStockQty,
    required this.availableUnits,
    required this.productUnitId,
    required this.unitCode,
    required this.conversionFactor,
    this.quantity = 1,
  }) : qtyCtrl = TextEditingController(text: '1');

  double get unitPrice => basePrice * conversionFactor;
  double get subtotal => unitPrice * quantity;

  double? get availableInSelectedUnit {
    if (baseStockQty == null || conversionFactor == 0) return null;
    return baseStockQty! / conversionFactor;
  }

  bool get isOverStock {
    final avail = availableInSelectedUnit;
    if (avail == null) return false;
    return quantity > avail;
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'sku': sku,
        'productName': productName,
        'basePrice': basePrice,
        'baseStockQty': baseStockQty,
        'productUnitId': productUnitId,
        'unitCode': unitCode,
        'conversionFactor': conversionFactor,
        'quantity': quantity,
      };

  void dispose() => qtyCtrl.dispose();
}

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  static const String _draftKey = 'invoice_draft';

  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customerCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _categories = [];
  final List<InvoiceItem> _invoice = [];
  bool _loadingProducts = true;
  bool _saving = false;
  bool _printing = false;
  Timer? _draftTimer;

  String _paymentMethod = 'cash';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _bootstrap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  Future<void> _bootstrap() async {
    await _loadCategories();
    await _loadProducts(_searchCtrl.text);
    await _restoreDraftIfAny();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _searchCtrl.dispose();
    _customerCtrl.dispose();
    _searchFocus.dispose();
    for (final it in _invoice) {
      it.dispose();
    }
    super.dispose();
  }

  void _scheduleDraftSave() {
    _draftTimer?.cancel();
    _draftTimer = Timer(const Duration(milliseconds: 800), _saveDraftNow);
  }

  Future<void> _saveDraftNow() async {
    if (_invoice.isEmpty &&
        _customerCtrl.text.trim().isEmpty &&
        _paymentMethod == 'cash') {
      await LocalDatabase.instance.clearDraft(_draftKey);
      return;
    }
    await LocalDatabase.instance.saveDraft(_draftKey, {
      'items': _invoice.map((it) => it.toJson()).toList(),
      'paymentMethod': _paymentMethod,
      'customerName': _customerCtrl.text.trim(),
    });
  }

  Future<void> _clearDraft() async {
    _draftTimer?.cancel();
    await LocalDatabase.instance.clearDraft(_draftKey);
  }

  Future<void> _restoreDraftIfAny() async {
    final draft = await LocalDatabase.instance.loadDraft(_draftKey);
    if (draft == null) return;

    final itemsJson = draft['items'];
    if (itemsJson is! List || itemsJson.isEmpty) {
      await _clearDraft();
      return;
    }

    if (!mounted) return;
    final shouldRestore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة الفاتورة السابقة؟'),
        content: const Text(
            'يوجد فاتورة غير محفوظة من جلسة سابقة. هل تريد استعادتها؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('لا، احذفها'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('نعم، استعدها'),
          ),
        ],
      ),
    );

    if (shouldRestore != true) {
      await _clearDraft();
      return;
    }

    final newItems = <InvoiceItem>[];
    for (final raw in itemsJson) {
      if (raw is! Map) continue;
      final map = Map<String, dynamic>.from(raw);
      final productId = map['productId'] as String?;
      if (productId == null) continue;

      final units = await LocalDatabase.instance.getProductUnits(productId);
      if (units.isEmpty) continue;

      final qty = (map['quantity'] as num?)?.toDouble() ?? 1.0;
      final item = InvoiceItem(
        productId: productId,
        sku: map['sku'] as String? ?? '',
        productName: map['productName'] as String? ?? '—',
        basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0,
        baseStockQty: (map['baseStockQty'] as num?)?.toDouble(),
        availableUnits: units,
        productUnitId: map['productUnitId'] as String? ?? units.first['id'] as String,
        unitCode: map['unitCode'] as String? ?? units.first['unit_code'] as String,
        conversionFactor: (map['conversionFactor'] as num?)?.toDouble() ??
            (units.first['conversion_factor'] as num).toDouble(),
        quantity: qty,
      );
      item.qtyCtrl.text = qty.toString();
      newItems.add(item);
    }

    if (!mounted) return;
    setState(() {
      _invoice
        ..clear()
        ..addAll(newItems);
      _paymentMethod = (draft['paymentMethod'] as String?) ?? 'cash';
      final cn = draft['customerName'] as String?;
      if (cn != null && cn.isNotEmpty) _customerCtrl.text = cn;
    });
  }

  Future<void> _loadCategories() async {
    final cats = await LocalDatabase.instance.getUsedCategories();
    if (!mounted) return;
    setState(() => _categories = cats);
  }

  Future<void> _loadProducts(String query) async {
    final results = await LocalDatabase.instance.searchProducts(
      query,
      categorySlug: _selectedCategory,
    );
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _loadingProducts = false;
    });
  }

  void _changeCategory(String? slug) {
    setState(() {
      _selectedCategory = slug;
      _loadingProducts = true;
    });
    _loadProducts(_searchCtrl.text);
  }

  Future<void> _addToInvoice(Map<String, dynamic> product) async {
    final id = product['id'] as String;
    final units = await LocalDatabase.instance.getProductUnits(id);
    if (units.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد وحدات لهذا المنتج'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final defaultUnit = units.firstWhere(
      (u) => u['is_default'] == 1,
      orElse: () => units.first,
    );

    final stockQty = product['stock_qty'] == null
        ? null
        : (product['stock_qty'] as num).toDouble();

    setState(() {
      _invoice.add(InvoiceItem(
        productId: id,
        sku: product['sku'] as String? ?? '',
        productName: product['name'] as String,
        basePrice: (product['sale_price'] as num).toDouble(),
        baseStockQty: stockQty,
        availableUnits: units,
        productUnitId: defaultUnit['id'] as String,
        unitCode: defaultUnit['unit_code'] as String,
        conversionFactor:
            (defaultUnit['conversion_factor'] as num).toDouble(),
      ));
      _searchCtrl.clear();
      _searchResults = [];
    });
    _scheduleDraftSave();
    await _loadProducts('');
    _searchFocus.requestFocus();
  }

  Future<void> _submitFirstResult(String query) async {
    if (query.trim().isEmpty && _selectedCategory == null) return;
    if (_searchResults.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد نتائج'), duration: Duration(seconds: 1)),
      );
      return;
    }
    await _addToInvoice(_searchResults.first);
  }

  void _removeFromInvoice(int index) {
    setState(() {
      _invoice[index].dispose();
      _invoice.removeAt(index);
    });
    _scheduleDraftSave();
  }

  void _changeUnit(InvoiceItem item, String newUnitId) {
    final unit = item.availableUnits.firstWhere(
      (u) => u['id'] == newUnitId,
      orElse: () => item.availableUnits.first,
    );
    setState(() {
      item.productUnitId = unit['id'] as String;
      item.unitCode = unit['unit_code'] as String;
      item.conversionFactor =
          (unit['conversion_factor'] as num).toDouble();
    });
    _scheduleDraftSave();
  }

  void _changeQuantity(InvoiceItem item, String text) {
    final v = double.tryParse(text);
    if (v != null && v > 0) {
      setState(() => item.quantity = v);
      _scheduleDraftSave();
    }
  }

  void _clearInvoice() {
    if (_invoice.isEmpty) return;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح الفاتورة؟'),
        content: const Text('سيتم حذف جميع الأصناف من الفاتورة الحالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('نعم، امسح'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        for (final it in _invoice) {
          it.dispose();
        }
        setState(() {
          _invoice.clear();
          _customerCtrl.clear();
        });
        _scheduleDraftSave();
      }
    });
  }

  double get _total => _invoice.fold(0.0, (s, it) => s + it.subtotal);
  int get _itemCount => _invoice.length;
  double get _totalQuantity => _invoice.fold(0.0, (s, it) => s + it.quantity);

  ReceiptData _buildReceiptData({required String invoiceNumber}) {
    return ReceiptData(
      invoiceNumber: invoiceNumber,
      occurredAt: DateTime.now(),
      paymentMethod: _paymentMethod,
      customerName: _customerCtrl.text.trim().isEmpty
          ? null
          : _customerCtrl.text.trim(),
      total: _total,
      lines: _invoice
          .map((it) => ReceiptLine(
                productName: it.productName,
                sku: it.sku,
                unitCode: it.unitCode,
                quantity: it.quantity,
                unitPrice: it.unitPrice,
                subtotal: it.subtotal,
              ))
          .toList(),
    );
  }

  Future<void> _printInvoicePreview() async {
    if (_invoice.isEmpty || _printing) return;
    setState(() => _printing = true);
    try {
      final data = _buildReceiptData(invoiceNumber: 'مسودة');
      final bytes = await ReceiptService.generatePdf(data);
      await ReceiptService.previewPdf(bytes, 'مسودة');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم فتح معاينة الفاتورة'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الطباعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _printAfterSave(
      String invoiceNumber, ReceiptData data) async {
    try {
      final bytes = await ReceiptService.generatePdf(data);
      await ReceiptService.savePdfToDisk(bytes, invoiceNumber);
      await ReceiptService.previewPdf(bytes, invoiceNumber);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في طباعة الفاتورة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveInvoice() async {
    if (_invoice.isEmpty || _saving) return;

    if (_paymentMethod == 'credit' && _customerCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اسم العميل مطلوب عند البيع الآجل'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final items = _invoice
          .map((it) => {
                'product_id': it.productId,
                'product_name': it.productName,
                'quantity': it.quantity,
                'unit_price': it.unitPrice,
                'subtotal': it.subtotal,
                'product_unit_id': it.productUnitId,
                'unit_code': it.unitCode,
                'conversion_factor': it.conversionFactor,
              })
          .toList();

      final result = await LocalDatabase.instance.saveInvoice(
        items: items,
        total: _total,
        paymentMethod: _paymentMethod,
        customerName: _customerCtrl.text.trim().isEmpty
            ? null
            : _customerCtrl.text.trim(),
      );

      await _clearDraft();

      final invoiceNumber = result['invoice_number'].toString();
      final savedData = _buildReceiptData(invoiceNumber: invoiceNumber);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الفاتورة رقم $invoiceNumber'),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'طباعة',
            textColor: Colors.white,
            onPressed: () => _printAfterSave(invoiceNumber, savedData),
          ),
        ),
      );

      for (final it in _invoice) {
        it.dispose();
      }
      setState(() {
        _invoice.clear();
        _searchCtrl.clear();
        _searchResults = [];
        _customerCtrl.clear();
        _saving = false;
      });
      await _loadProducts('');
      _searchFocus.requestFocus();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: ' + e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة جديدة'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'إغلاق',
          onPressed: _saving
              ? null
              : () async {
                  await _saveDraftNow();
                  if (!mounted) return;
                  if (_invoice.isEmpty) {
                    Navigator.pop(context);
                  } else {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('خروج بدون حفظ؟'),
                        content: const Text(
                            'سيتم حفظ الفاتورة كمسودة لاستعادتها لاحقاً.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('بقاء'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('خروج'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          if (_hasActiveQuery) _buildSearchResults(),
          Expanded(child: _buildInvoiceList()),
          _buildTotalBar(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  bool get _hasActiveQuery =>
      _searchCtrl.text.trim().isNotEmpty || _selectedCategory != null;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Row(
            children: [
              const Text('طريقة الدفع:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('نقد'),
                selected: _paymentMethod == 'cash',
                onSelected: (_) {
                  setState(() => _paymentMethod = 'cash');
                  _scheduleDraftSave();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('أجل'),
                selected: _paymentMethod == 'credit',
                onSelected: (_) {
                  setState(() => _paymentMethod = 'credit');
                  _scheduleDraftSave();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customerCtrl,
            onChanged: (_) => _scheduleDraftSave(),
            decoration: InputDecoration(
              hintText: _paymentMethod == 'credit'
                  ? 'اسم العميل (مطلوب للآجل)'
                  : 'اسم العميل (اختياري)',
              prefixIcon: const Icon(Icons.person_outline),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              focusNode: _searchFocus,
              onChanged: _loadProducts,
              onSubmitted: _submitFirstResult,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج... (Enter لإضافة أول نتيجة)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: 'مسح البحث',
                        onPressed: () {
                          _searchCtrl.clear();
                          _loadProducts('');
                          _searchFocus.requestFocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 220, child: _buildCategoryDropdown()),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String?>(
      value: _selectedCategory,
      isDense: true,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'التصنيف',
        prefixIcon: const Icon(Icons.category_outlined, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        suffixIcon: _selectedCategory != null
            ? IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'إزالة الفلتر',
                onPressed: () => _changeCategory(null),
              )
            : null,
      ),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        ..._categories.map((c) {
          final name = c['name'] as String? ?? c['slug'] as String;
          final cnt = c['cnt'] as int? ?? 0;
          return DropdownMenuItem<String?>(
            value: c['slug'] as String,
            child: Text('$name ($cnt)', overflow: TextOverflow.ellipsis),
          );
        }),
      ],
      onChanged: _changeCategory,
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: _loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : _searchResults.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('لا توجد نتائج'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, i) {
                    final p = _searchResults[i];
                    final stockQty = p['stock_qty'] == null
                        ? null
                        : (p['stock_qty'] as num).toDouble();
                    final unitCode = p['unit_id'] as String? ?? '';
                    final sku = p['sku'] as String? ?? '';
                    final isFirst = i == 0;
                    return ListTile(
                      dense: true,
                      selected: isFirst,
                      selectedTileColor: Colors.blue.shade50,
                      leading: Icon(
                        isFirst ? Icons.keyboard_return : Icons.add_circle_outline,
                        color: isFirst ? Colors.blue : null,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(p['name'].toString(),
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (sku.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(sku,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                    fontFamily: 'monospace',
                                  )),
                            ),
                          ],
                        ],
                      ),
                      subtitle: _stockIndicator(stockQty, unitCode),
                      trailing: Text(p['sale_price'].toString() + ' YER',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => _addToInvoice(p),
                    );
                  },
                ),
    );
  }

  Widget _stockIndicator(double? stockQty, String unitCode) {
    if (stockQty == null) {
      return Text('المتاح: -',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600));
    }
    final isZero = stockQty <= 0;
    final isLow = stockQty > 0 && stockQty < 5;
    final color = isZero
        ? Colors.red
        : (isLow ? Colors.orange.shade800 : Colors.grey.shade700);
    return Text(
      'المتاح: ' + stockQty.toStringAsFixed(2) + ' ' + unitCode,
      style: TextStyle(fontSize: 11, color: color),
    );
  }

  Widget _buildInvoiceList() {
    if (_invoice.isEmpty) {
      return Container(
        color: Colors.grey.shade100,
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('الفاتورة فارغة',
                  style: TextStyle(fontSize: 18, color: Colors.grey)),
              SizedBox(height: 8),
              Text('ابحث عن منتج لإضافته',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _invoice.length,
      itemBuilder: (context, i) {
        final item = _invoice[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(item.productName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    if (item.isOverStock)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(Icons.warning_amber_rounded,
                            color: Colors.orange, size: 20),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromInvoice(i),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: item.productUnitId,
                        isDense: true,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        items: item.availableUnits.map((u) {
                          final code = u['unit_code'] as String;
                          final f = (u['conversion_factor'] as num).toDouble();
                          final price = item.basePrice * f;
                          return DropdownMenuItem<String>(
                            value: u['id'] as String,
                            child: Text('$code (${price.toStringAsFixed(0)})',
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) _changeUnit(item, v);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: item.qtyCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'الكمية',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          errorText: item.isOverStock ? 'أكثر من المتاح' : null,
                        ),
                        onChanged: (v) => _changeQuantity(item, v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('سعر الوحدة: ${item.unitPrice.toStringAsFixed(0)} YER',
                        style: TextStyle(color: Colors.grey.shade700)),
                    Text('${item.subtotal.toStringAsFixed(0)} YER',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
                if (item.availableInSelectedUnit != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 14,
                          color: item.isOverStock
                              ? Colors.orange.shade800
                              : Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'المتاح: ${item.availableInSelectedUnit!.toStringAsFixed(2)} ${item.unitCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: item.isOverStock
                              ? Colors.orange.shade800
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الإجمالي:',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                Text('${_total.toStringAsFixed(0)} YER',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$_itemCount صنف',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('كمية: ${_totalQuantity.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              label: const Text('مسح',
                  style: TextStyle(color: Colors.red)),
              onPressed:
                  _invoice.isEmpty || _saving ? null : _clearInvoice,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 44,
            child: OutlinedButton(
              onPressed: (_invoice.isEmpty || _printing)
                  ? null
                  : _printInvoicePreview,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(color: Colors.blue.shade300),
              ),
              child: _printing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.print, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'جاري الحفظ...' : 'حفظ الفاتورة'),
              onPressed: _invoice.isEmpty || _saving ? null : _saveInvoice,
            ),
          ),
        ],
      ),
    );
  }
}
