// lib/services/product_admin_service.dart
// v8.3.8.3 — خدمة إدارة المنتجات (SQLite-first, read-only)
// تجسيد محلي لـ v_products_review في Hasura — نفس المنطق.

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// أنواع المراجعة — مطابقة لمفاهيم v_products_review
enum ReviewReason { fullPlaceholder, zeroCost, lossMaking }

/// فلاتر القائمة الرئيسية
enum ProductFilter { all, anomalies, zeroCost, lossMaking, fullPlaceholder }

extension ProductFilterExt on ProductFilter {
  String get labelAr {
    switch (this) {
      case ProductFilter.all:              return 'الكل';
      case ProductFilter.anomalies:        return 'يحتاج مراجعة';
      case ProductFilter.zeroCost:         return 'تكلفة صفر';
      case ProductFilter.lossMaking:       return 'خاسر';
      case ProductFilter.fullPlaceholder:  return 'فارغ تماماً';
    }
  }

  /// شرط SQL المقابل (بدون WHERE)
  String? get whereClause {
    switch (this) {
      case ProductFilter.all:              return null;
      case ProductFilter.anomalies:        return '(standard_cost = 0 OR sale_price <= standard_cost)';
      case ProductFilter.zeroCost:         return 'standard_cost = 0 AND sale_price > 0';
      case ProductFilter.lossMaking:       return 'standard_cost > 0 AND sale_price <= standard_cost';
      case ProductFilter.fullPlaceholder:  return 'standard_cost = 0 AND sale_price = 0';
    }
  }
}

class ProductAdminService {
  final Database db;

  ProductAdminService(this.db);

  static const String _selectCols =
      'id, sku, name, category_slug, standard_cost, sale_price, stock_qty, unit_id';

  // v8.3.8.5 — استنساخ _arabicVariants من local_db.dart
  // توليد بدائل عربية عند البحث (ي/ى، ة/ه، ا/أ/إ)
  List<String> _arabicVariants(String word, {int max = 12}) {
    final r = <String>{word};
    final sub = <String, List<String>>{
      'ا': ['ا','أ','إ'],
      'أ': ['ا','أ','إ'],
      'إ': ['ا','أ','إ'],
      'ي': ['ي','ى'],
      'ى': ['ي','ى'],
      'ه': ['ه','ة'],
      'ة': ['ه','ة'],
    };
    void exp(String s, int p) {
      if (r.length >= max || p >= s.length) return;
      final ch = s[p];
      final vs = sub[ch];
      if (vs != null) {
        for (final v in vs) {
          if (v != ch) {
            final n = s.substring(0,p)+v+s.substring(p+1);
            if (r.add(n)) exp(n, p+1);
          }
        }
      }
      exp(s, p+1);
    }
    exp(word, 0);
    return r.take(max).toList();
  }


  // ══════════════════════════════════════════════════════════
  // [1] القائمة الرئيسية — بحث + فلتر + ترتيب + ترقيم
  // ══════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getAll({
    String? search,
    ProductFilter filter = ProductFilter.all,
    String orderBy = 'name',
    bool ascending = true,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final whereParts = <String>[];
      final args = <Object>[];

      // فلتر الحالة
      final filterWhere = filter.whereClause;
      if (filterWhere != null) whereParts.add('(' + filterWhere + ')');

      // بحث
      if (search != null && search.trim().isNotEmpty) {
        final words = search.trim()
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();
        for (final w in words) {
          final variants = _arabicVariants(w);
          final variantParts = <String>[];
          for (final v in variants) {
            variantParts.add('(name LIKE ? OR sku LIKE ?)');
            final q = '%' + v + '%';
            args.add(q);
            args.add(q);
          }
          if (variantParts.isNotEmpty) {
            whereParts.add('(' + variantParts.join(' OR ') + ')');
          }
        }
      }

      final whereStr = whereParts.isEmpty ? '' : 'WHERE ' + whereParts.join(' AND ');
      final direction = ascending ? 'ASC' : 'DESC';
      final orderStr = 'ORDER BY ' + orderBy + ' ' + direction;
      final cols = _selectCols;

      final sql = 'SELECT ' + cols + ' FROM products_local ' +
                  whereStr + ' ' + orderStr + ' LIMIT ? OFFSET ?';

      args.add(limit);
      args.add(offset);

      return await db.rawQuery(sql, args);
    } catch (e) {
      debugPrint('ProductAdminService.getAll error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // [2] المراجحة — تجسيد v_products_review
  // ══════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getAnomalies({int limit = 500}) async {
    try {
      final sql = '''
        SELECT id, sku, name, category_slug, standard_cost, sale_price, stock_qty, unit_id,
          CASE
            WHEN standard_cost = 0 AND sale_price = 0 THEN 'full_placeholder'
            WHEN standard_cost = 0 THEN 'zero_cost'
            WHEN sale_price <= standard_cost THEN 'loss_making'
          END AS review_reason
        FROM products_local
        WHERE standard_cost = 0 OR sale_price <= standard_cost
        ORDER BY
          CASE
            WHEN standard_cost = 0 AND sale_price = 0 THEN 1
            WHEN standard_cost = 0 THEN 2
            WHEN sale_price <= standard_cost THEN 3
          END,
          name ASC
        LIMIT ?
      ''';
      return await db.rawQuery(sql, [limit]);
    } catch (e) {
      debugPrint('ProductAdminService.getAnomalies error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // [3] إحصاءات سريعة — للـheader في الشاشة
  // ══════════════════════════════════════════════════════════
  Future<Map<String, int>> getStats() async {
    try {
      final r = await db.rawQuery('''
        SELECT
          COUNT(*) AS total,
          SUM(CASE WHEN standard_cost = 0 AND sale_price = 0 THEN 1 ELSE 0 END) AS full_placeholder,
          SUM(CASE WHEN standard_cost = 0 AND sale_price > 0 THEN 1 ELSE 0 END) AS zero_cost,
          SUM(CASE WHEN standard_cost > 0 AND sale_price <= standard_cost THEN 1 ELSE 0 END) AS loss_making
        FROM products_local
      ''');
      if (r.isEmpty) {
        return {'total': 0, 'full_placeholder': 0, 'zero_cost': 0, 'loss_making': 0};
      }
      final row = r.first;
      return {
        'total':            (row['total'] as int?) ?? 0,
        'full_placeholder': (row['full_placeholder'] as int?) ?? 0,
        'zero_cost':        (row['zero_cost'] as int?) ?? 0,
        'loss_making':      (row['loss_making'] as int?) ?? 0,
      };
    } catch (e) {
      debugPrint('ProductAdminService.getStats error: $e');
      return {'total': 0, 'full_placeholder': 0, 'zero_cost': 0, 'loss_making': 0};
    }
  }

  // ══════════════════════════════════════════════════════════
  // [4] عدّاد التصنيفات — للـFilter Chips
  // ══════════════════════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getCategoryCounts() async {
    try {
      return await db.rawQuery('''
        SELECT category_slug, COUNT(*) AS cnt
        FROM products_local
        WHERE category_slug IS NOT NULL AND category_slug != ''
        GROUP BY category_slug
        ORDER BY cnt DESC, category_slug ASC
      ''');
    } catch (e) {
      debugPrint('ProductAdminService.getCategoryCounts error: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════════
  // [5] منتج واحد بالتفصيل
  // ══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>?> getById(String id) async {
    try {
      final r = await db.query('products_local',
          where: 'id = ?', whereArgs: [id], limit: 1);
      return r.isEmpty ? null : r.first;
    } catch (e) {
      debugPrint('ProductAdminService.getById error: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════
  // [6] تعديل منتج — v8.3.8.7
  // يضع synced_at = '' → يُعلَّم كـ pending للمزامنة
  // ══════════════════════════════════════════════════════════
  Future<int> updateProduct(
    String id, {
    double? standardCost,
    double? salePrice,
    String? categorySlug,
  }) async {
    final values = <String, dynamic>{'synced_at': ''};
    if (standardCost != null) values['standard_cost'] = standardCost;
    if (salePrice != null) values['sale_price'] = salePrice;
    if (categorySlug != null) values['category_slug'] = categorySlug;

    return db.update(
      'products_local',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
