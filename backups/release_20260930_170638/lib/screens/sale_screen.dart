import 'package:flutter/material.dart';
import '../db/local_db.dart';

class InvoiceItem {
  final String productId;
  final String productName;
  final double basePrice;
  final List<Map<String, dynamic>> availableUnits;
  String productUnitId;
  String unitCode;
  double conversionFactor;
  double quantity;
  final TextEditingController qtyCtrl;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.availableUnits,
    required this.productUnitId,
    required this.unitCode,
    required this.conversionFactor,
    this.quantity = 1,
  }) : qtyCtrl = TextEditingController(text: '1');

  double get unitPrice => basePrice * conversionFactor;
  double get subtotal => unitPrice * quantity;

  void dispose() => qtyCtrl.dispose();
}

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _customerCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final List<InvoiceItem> _invoice = [];
  bool _loadingProducts = true;
  bool _saving = false;
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _loadProducts('');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _customerCtrl.dispose();
    for (final it in _invoice) {
      it.dispose();
    }
    super.dispose();
  }

  Future<void> _loadProducts(String query) async {
    final results = await LocalDatabase.instance.searchProducts(query);
    if (!mounted) return;
    setState(() {
      _searchResults = results;
      _loadingProducts = false;
    });
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

    setState(() {
      _invoice.add(InvoiceItem(
        productId: id,
        productName: product['name'] as String,
        basePrice: (product['sale_price'] as num).toDouble(),
        availableUnits: units,
        productUnitId: defaultUnit['id'] as String,
        unitCode: defaultUnit['unit_code'] as String,
        conversionFactor:
            (defaultUnit['conversion_factor'] as num).toDouble(),
      ));
      _searchCtrl.clear();
      _searchResults = [];
    });
    await _loadProducts('');
  }

  void _removeFromInvoice(int index) {
    setState(() {
      _invoice[index].dispose();
      _invoice.removeAt(index);
    });
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
  }

  void _changeQuantity(InvoiceItem item, String text) {
    final v = double.tryParse(text);
    if (v != null && v > 0) {
      setState(() => item.quantity = v);
    }
  }

  double get _total => _invoice.fold(0.0, (s, it) => s + it.subtotal);

  Future<void> _saveInvoice() async {
    if (_invoice.isEmpty || _saving) return;

    if (_paymentMethod == 'credit' &&
        _customerCtrl.text.trim().isEmpty) {
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

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ الفاتورة رقم ' +
                result['invoice_number'].toString() +
                ' — في انتظار المزامنة',
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 4),
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
        _paymentMethod = 'cash';
        _saving = false;
      });
      await _loadProducts('');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ' + e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فاتورة جديدة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          if (_searchCtrl.text.trim().isNotEmpty) _buildSearchResults(),
          Expanded(child: _buildInvoiceList()),
          _buildTotalBar(),
          _buildActionButtons(),
        ],
      ),
    );
  }

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
                onSelected: (_) =>
                    setState(() => _paymentMethod = 'cash'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('أجل'),
                selected: _paymentMethod == 'credit',
                onSelected: (_) =>
                    setState(() => _paymentMethod = 'credit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customerCtrl,
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
      child: TextField(
        controller: _searchCtrl,
        onChanged: _loadProducts,
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
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
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.add_circle_outline),
                      title: Text(p['name'].toString()),
                      trailing: Text(
                        p['sale_price'].toString() + ' YER',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _addToInvoice(p),
                    );
                  },
                ),
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
              Icon(Icons.shopping_cart_outlined,
                  size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'الفاتورة فارغة',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'ابحث عن منتج لإضافته',
                style: TextStyle(color: Colors.grey),
              ),
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
                      child: Text(
                        item.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                        decoration: const InputDecoration(
                          labelText: 'الوحدة',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8),
                        ),
                        items: item.availableUnits.map((u) {
                          final code = u['unit_code'] as String;
                          final f = (u['conversion_factor'] as num).toDouble();
                          final price = item.basePrice * f;
                          return DropdownMenuItem<String>(
                            value: u['id'] as String,
                            child: Text(code +
                                ' (' +
                                price.toStringAsFixed(0) +
                                ')'),
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
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'الكمية',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8),
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
                    Text(
                      'سعر الوحدة: ' +
                          item.unitPrice.toStringAsFixed(0) +
                          ' YER',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    Text(
                      item.subtotal.toStringAsFixed(0) + ' YER',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue.shade50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الإجمالي:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            _total.toStringAsFixed(0) + ' YER',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
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
              icon: const Icon(Icons.cancel),
              label: const Text('إلغاء'),
              onPressed: _saving ? null : () => Navigator.pop(context),
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
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label:
                  Text(_saving ? 'جاري الحفظ...' : 'حفظ الفاتورة'),
              onPressed:
                  _invoice.isEmpty || _saving ? null : _saveInvoice,
            ),
          ),
        ],
      ),
    );
  }
}
