// lib/widgets/products/product_filter_bar.dart
// -----------------------------------------------------------------
// شريط الفلاتر الذكية + بطاقات الإحصاء
// مستخرج من الشاشة المكررة product_list_screen.dart
// الغرض: زرعه في تبويب (القائمة) داخل شاشة الأصناف المعتمدة
// -----------------------------------------------------------------
import 'package:flutter/material.dart';

enum ProductFilter {
  all,          // الكل
  needsReview,  // يحتاج مراجعة
  zeroCost,     // تكلفة صفر
  lossMaking,   // خاسر
  empty,        // فارغ تماماً
}

extension ProductFilterX on ProductFilter {
  String get label {
    switch (this) {
      case ProductFilter.all: return 'الكل';
      case ProductFilter.needsReview: return 'يحتاج مراجعة';
      case ProductFilter.zeroCost: return 'تكلفة صفر';
      case ProductFilter.lossMaking: return 'خاسر';
      case ProductFilter.empty: return 'فارغ تماماً';
    }
  }
}

class ProductFilterBar extends StatelessWidget {
  final ProductFilter current;
  final int totalCount;
  final int needsReviewCount;
  final int zeroCostCount;
  final int lossMakingCount;
  final int emptyCount;
  final ValueChanged<ProductFilter> onChanged;

  const ProductFilterBar({
    super.key,
    required this.current,
    required this.totalCount,
    required this.needsReviewCount,
    required this.zeroCostCount,
    required this.lossMakingCount,
    required this.emptyCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- بطاقات الإحصاء ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              _statCard('إجمالي', totalCount, const Color(0xFF1E3A5F), const Color(0xFFEFF4FA)),
              const SizedBox(width: 6),
              _statCard('فارغ', emptyCount, const Color(0xFF7F1D1D), const Color(0xFFFEE2E2)),
              const SizedBox(width: 6),
              _statCard('صفر', zeroCostCount, const Color(0xFF92400E), const Color(0xFFFEF3C7)),
              const SizedBox(width: 6),
              _statCard('خاسر', lossMakingCount, const Color(0xFF991B1B), const Color(0xFFFEE2E2)),
            ],
          ),
        ),
        // --- أزرار الفلترة ---
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              _chip(ProductFilter.all, totalCount),
              const SizedBox(width: 6),
              _chip(ProductFilter.needsReview, needsReviewCount),
              const SizedBox(width: 6),
              _chip(ProductFilter.zeroCost, zeroCostCount),
              const SizedBox(width: 6),
              _chip(ProductFilter.lossMaking, lossMakingCount),
              const SizedBox(width: 6),
              _chip(ProductFilter.empty, emptyCount),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _chip(ProductFilter f, int count) {
    final selected = current == f;
    return ChoiceChip(
      label: Text(
        '${f.label} ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : const Color(0xFF374151),
        ),
      ),
      selected: selected,
      onSelected: (_) => onChanged(f),
      selectedColor: const Color(0xFF1E3A5F),
      backgroundColor: const Color(0xFFF3F4F6),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _statCard(String label, int value, Color fg, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: fg.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: fg),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: fg.withValues(alpha: 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}