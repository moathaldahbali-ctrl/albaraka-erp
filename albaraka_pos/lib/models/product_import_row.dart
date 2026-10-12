// A single row parsed from the Excel import file.
// Stock quantity is intentionally ignored in the first import batch.
// It will be filled later via an Opening Balance document.
class ProductImportRow {
  final int rowNumber;
  final String sku;
  final String name;
  final String? unitCode;
  final double standardCost;
  final double salePrice;
  final String? categorySlug;

  String? error;
  String? warning;

  ProductImportRow({
    required this.rowNumber,
    required this.sku,
    required this.name,
    this.unitCode,
    required this.standardCost,
    required this.salePrice,
    this.categorySlug,
    this.error,
    this.warning,
  });

  bool get isValid => error == null;

  String get effectiveUnitCode {
    final u = (unitCode ?? '').trim();
    return u.isEmpty ? 'unit' : u;
  }

  String get effectiveCategorySlug {
    final c = (categorySlug ?? '').trim();
    return c.isEmpty ? 'unclassified' : c;
  }

  Map<String, Object?> toProductsLocal({required String id}) =>
      <String, Object?>{
        'id': id,
        'name': name,
        'sku': sku,
        'standard_cost': standardCost,
        'sale_price': salePrice,
        'unit_id': effectiveUnitCode,
        'category_slug': effectiveCategorySlug,
        'stock_qty': 0.0,
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      };

  Map<String, Object?> toDefaultProductUnit({
    required String id,
    required String productId,
  }) =>
      <String, Object?>{
        'id': id,
        'product_id': productId,
        'unit_code': effectiveUnitCode,
        'conversion_factor': 1.0,
        'is_default': 1,
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      };

  @override
  String toString() =>
      'ProductImportRow(#' + rowNumber.toString() + ' sku=' + sku + ' name=' + name + ' err=' + (error ?? 'null') + ')';
}
