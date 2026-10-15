// lib/widgets/products/product_edit_dialog.dart
// v8.3.8.7 — Dialog تعديل منتج (cost + price + category_slug)
// يعمل على SQLite + يضع synced_at = '' للمزامنة

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// نتيجة الحفظ
class ProductEditResult {
  final bool saved;
  final bool didSync;

  const ProductEditResult({required this.saved, this.didSync = false});
}

class ProductEditDialog extends StatefulWidget {
  final String productId;
  final String productName;
  final String sku;
  final double currentCost;
  final double currentPrice;
  final String currentCategorySlug;
  final List<Map<String, dynamic>> categories;

  /// دالة الحفظ — تُمرَّر من الخارج (من ProductDetailScreen)
  /// تُرجع عدد السجلات المُحدَّثة (> 0 = نجاح)
  final Future<int> Function({
    required double standardCost,
    required double salePrice,
    required String categorySlug,
  }) onSave;

  const ProductEditDialog({
    super.key,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.currentCost,
    required this.currentPrice,
    required this.currentCategorySlug,
    required this.categories,
    required this.onSave,
  });

  @override
  State<ProductEditDialog> createState() => _ProductEditDialogState();
}

class _ProductEditDialogState extends State<ProductEditDialog> {
  late final TextEditingController _costCtrl;
  late final TextEditingController _priceCtrl;
  late String _selectedCategorySlug;

  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _costCtrl = TextEditingController(
      text: widget.currentCost.toStringAsFixed(2),
    );
    _priceCtrl = TextEditingController(
      text: widget.currentPrice.toStringAsFixed(2),
    );
    _selectedCategorySlug = widget.currentCategorySlug;
  }

  @override
  void dispose() {
    _costCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════
  // التحقق
  // ═══════════════════════════════════════════════════════════
  String? _validateCost(String? v) {
    if (v == null || v.trim().isEmpty) return 'التكلفة مطلوبة';
    final n = double.tryParse(v.trim());
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n < 0) return 'التكلفة لا يمكن أن تكون سالبة';
    return null;
  }

  String? _validatePrice(String? v) {
    if (v == null || v.trim().isEmpty) return 'سعر البيع مطلوب';
    final n = double.tryParse(v.trim());
    if (n == null) return 'أدخل رقماً صحيحاً';
    if (n < 0) return 'السعر لا يمكن أن يكون سالباً';
    return null;
  }

  // ═══════════════════════════════════════════════════════════
  // الحفظ
  // ═══════════════════════════════════════════════════════════
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cost = double.parse(_costCtrl.text.trim());
    final price = double.parse(_priceCtrl.text.trim());

    // تحذير لو خاسر
    if (price <= cost) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تحذير'),
          content: Text(
            'سعر البيع ($price) أقل من أو يساوي التكلفة ($cost).\n'
            'هل أنت متأكد من الحفظ؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('متابعة'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => _saving = true);

    try {
      final affected = await widget.onSave(
        standardCost: cost,
        salePrice: price,
        categorySlug: _selectedCategorySlug,
      );

      if (!mounted) return;

      if (affected > 0) {
        Navigator.pop(
          context,
          const ProductEditResult(saved: true, didSync: false),
        );
      } else {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم أي تعديل')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تعديل: ${widget.productName}',
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SKU (للقراءة)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_2, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          widget.sku,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // التكلفة
                  TextFormField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'التكلفة',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateCost,
                    textInputAction: TextInputAction.next,
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 12),

                  // سعر البيع
                  TextFormField(
                    controller: _priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'سعر البيع',
                      prefixIcon: Icon(Icons.sell),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validatePrice,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                    enabled: !_saving,
                  ),
                  const SizedBox(height: 12),

                  // التصنيف
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategorySlug.isEmpty
                        ? null
                        : _selectedCategorySlug,
                    decoration: const InputDecoration(
                      labelText: 'التصنيف',
                      prefixIcon: Icon(Icons.category_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: widget.categories.map((c) {
                      final slug = c['slug'] as String;
                      final name = (c['name'] as String?) ?? slug;
                      return DropdownMenuItem(
                        value: slug,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: _saving
                        ? null
                        : (v) {
                            if (v != null) {
                              setState(() => _selectedCategorySlug = v);
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, size: 18),
            label: Text(_saving ? 'جاري الحفظ...' : 'حفظ'),
          ),
        ],
      ),
    );
  }
}
