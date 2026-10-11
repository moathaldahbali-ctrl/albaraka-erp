import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

/// v8.3.7b — خدمة إدارة وحدات الصنف والباركود
/// تعمل على SQLite المحلي. المزامنة مع Hasura تأتي لاحقاً.
class ProductUnitsService {
  final Database db;
  final _uuid = const Uuid();

  ProductUnitsService(this.db);

  // ══════════════════════════════════════════════════════════════
  // الوحدات (product_units_local)
  // ══════════════════════════════════════════════════════════════

  /// قراءة كل وحدات صنف معين (الافتراضية أولاً، ثم الأصغر عبوة)
  Future<List<Map<String, dynamic>>> getUnits(String productId) async {
    return db.query(
      'product_units_local',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'is_default DESC, conversion_factor ASC',
    );
  }

  /// إضافة وحدة جديدة (UUID جديد + synced_at = null للمزامنة)
  Future<String> addUnit({
    required String productId,
    required String unitCode,
    required double conversionFactor,
    bool isDefault = false,
  }) async {
    final id = _uuid.v4();
    await db.transaction((txn) async {
      if (isDefault) {
        // إزالة الافتراضية من كل وحدات الصنف
        await txn.update(
          'product_units_local',
          {'is_default': 0, 'synced_at': ''},
          where: 'product_id = ?',
          whereArgs: [productId],
        );
      }
      await txn.insert('product_units_local', {
        'id': id,
        'product_id': productId,
        'unit_code': unitCode,
        'conversion_factor': conversionFactor,
        'is_default': isDefault ? 1 : 0,
        'synced_at': '',
      });
    });
    return id;
  }

  /// تعديل وحدة (unit_code أو conversion_factor)
  Future<int> updateUnit(
    String unitId, {
    String? unitCode,
    double? conversionFactor,
  }) async {
    final values = <String, dynamic>{'synced_at': ''};
    if (unitCode != null) values['unit_code'] = unitCode;
    if (conversionFactor != null) values['conversion_factor'] = conversionFactor;

    return db.update(
      'product_units_local',
      values,
      where: 'id = ?',
      whereArgs: [unitId],
    );
  }

  /// حذف وحدة + كل باركوداتها (في transaction)
  Future<int> deleteUnit(String unitId) async {
    return db.transaction((txn) async {
      await txn.delete(
        'product_barcodes_local',
        where: 'product_unit_id = ?',
        whereArgs: [unitId],
      );
      return txn.delete(
        'product_units_local',
        where: 'id = ?',
        whereArgs: [unitId],
      );
    });
  }

  /// تعيين وحدة كافتراضية (يعيد تعيين الأخريات)
  Future<void> setDefaultUnit(String productId, String unitId) async {
    await db.transaction((txn) async {
      await txn.update(
        'product_units_local',
        {'is_default': 0, 'synced_at': ''},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
      await txn.update(
        'product_units_local',
        {'is_default': 1, 'synced_at': ''},
        where: 'id = ?',
        whereArgs: [unitId],
      );
    });
  }

  // ══════════════════════════════════════════════════════════════
  // الباركود (product_barcodes_local)
  // ══════════════════════════════════════════════════════════════

  /// كل باركودات صنف معين
  Future<List<Map<String, dynamic>>> getBarcodes(String productId) async {
    return db.query(
      'product_barcodes_local',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'barcode ASC',
    );
  }

  /// البحث عن صنف بواسطة الباركود (يُرجع product_id أو null)
  Future<String?> findByBarcode(String barcode) async {
    final rows = await db.query(
      'product_barcodes_local',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['product_id'] as String;
  }

  /// إضافة باركود جديد (للمنتج أو لوحدة معينة)
  Future<String> addBarcode({
    required String productId,
    String? productUnitId,
    required String barcode,
  }) async {
    final id = _uuid.v4();
    await db.insert('product_barcodes_local', {
      'id': id,
      'product_id': productId,
      'product_unit_id': productUnitId,
      'barcode': barcode,
      'synced_at': '',
    });
    return id;
  }

  /// تعديل باركود (القيمة أو ربطه بوحدة)
  Future<int> updateBarcode(
    String barcodeId, {
    String? barcode,
    String? productUnitId,
  }) async {
    final values = <String, dynamic>{'synced_at': ''};
    if (barcode != null) values['barcode'] = barcode;
    // product_unit_id يمكن أن يكون null صراحةً (لتغيير الوحدة إلى "المنتج الأساسي")
    values['product_unit_id'] = productUnitId;

    return db.update(
      'product_barcodes_local',
      values,
      where: 'id = ?',
      whereArgs: [barcodeId],
    );
  }

  /// حذف باركود
  Future<int> deleteBarcode(String barcodeId) async {
    return db.delete(
      'product_barcodes_local',
      where: 'id = ?',
      whereArgs: [barcodeId],
    );
  }

  /// هل الباركود مستخدم في صنف آخر؟ (لمنع التعارض)
  Future<bool> isBarcodeTaken(String barcode, {String? excludeId}) async {
    final where = excludeId == null
        ? 'barcode = ?'
        : 'barcode = ? AND id != ?';
    final args = excludeId == null ? [barcode] : [barcode, excludeId];
    final rows = await db.query(
      'product_barcodes_local',
      where: where,
      whereArgs: args,
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}