// lib/widgets/products/product_admin_card.dart
// v8.3.8.3 — بطاقة منتج للقائمة الإدارية
// تعرض: الاسم، SKU، التصنيف، التكلفة، البيع، الرصيد + شارة التحذير

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'anomaly_badge.dart';

class ProductAdminCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onTap;
  final Map<String, String> categoryNameMap;

  const ProductAdminCard({
    super.key,
    required this.product,
    this.onTap,
    this.categoryNameMap = const {},
  });

  @override
  Widget build(BuildContext context) {
    final sku = (product['sku'] as String?) ?? '—';
    final name = (product['name'] as String?) ?? '—';
    final categorySlug = (product['category_slug'] as String?) ?? '';
    final cost = (product['standard_cost'] as num?)?.toDouble() ?? 0.0;
    final price = (product['sale_price'] as num?)?.toDouble() ?? 0.0;
    final stock = (product['stock_qty'] as num?)?.toDouble() ?? 0.0;
    final reason = product['review_reason'] as String?;

    final currency = NumberFormat('#,##0', 'en_US');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ═══ السطر 1: الاسم + شارة التحذير ═══
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (reason != null && reason.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    AnomalyBadge(reason: reason),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // ═══ السطر 2: SKU + التصنيف ═══
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _chip(sku, Icons.qr_code_2, const Color(0xFF455A64)),
                  if (categorySlug.isNotEmpty)
                    _chip(categoryNameMap[categorySlug] ?? categorySlug, Icons.category_outlined,
                        const Color(0xFF3F51B5)),
                ],
              ),

              const Divider(height: 18),

              // ═══ السطر 3: التكلفة | البيع | الرصيد ═══
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      'التكلفة',
                      currency.format(cost),
                      const Color(0xFF546E7A),
                    ),
                  ),
                  Expanded(
                    child: _metric(
                      'سعر البيع',
                      currency.format(price),
                      const Color(0xFF2E7D32),
                    ),
                  ),
                  Expanded(
                    child: _metric(
                      'الرصيد',
                      _fmtQty(stock),
                      const Color(0xFFEF6C00),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  String _fmtQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toStringAsFixed(2);
  }
}
