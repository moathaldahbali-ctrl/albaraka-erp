// lib/sync/product_admin_sync_service.dart
// v8.3.8.7 — مزامنة تعديلات المنتجات مع Hasura
// يستخدم نمط synced_at: NULL/'' = pending

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../db/local_db.dart';

/// نتيجة المزامنة
class ProductAdminSyncResult {
  final bool success;
  final int synced;
  final int failed;

  const ProductAdminSyncResult({
    required this.success,
    required this.synced,
    required this.failed,
  });
}

/// خدمة مزامنة تعديلات المنتجات
/// - تقرأ من products_local WHERE synced_at IS NULL OR synced_at = ''
/// - ترسل UPDATE إلى Hasura
/// - تُحدّث synced_at بعد النجاح
class ProductAdminSyncService {
  static const String _mutation = r'''
    mutation UpdateProduct($id: uuid!, $cost: numeric, $price: numeric) {
      update_products_by_pk(
        pk_columns: {id: $id},
        _set: {standard_cost: $cost, sale_price: $price}
      ) {
        id
      }
    }
  ''';

  /// المزامنة الرئيسية
  static Future<ProductAdminSyncResult> syncPendingProducts(
    GraphQLClient client,
  ) async {
    final db = await LocalDatabase.instance.database;

    final pending = await db.query(
      'products_local',
      where: "synced_at IS NULL OR synced_at = ''",
      orderBy: 'name ASC',
    );

    if (pending.isEmpty) {
      return const ProductAdminSyncResult(
        success: true,
        synced: 0,
        failed: 0,
      );
    }

    int synced = 0;
    int failed = 0;

    for (final p in pending) {
      try {
        final ok = await _syncOne(client, db, p);
        if (ok) {
          synced++;
        } else {
          failed++;
        }
      } catch (e) {
        debugPrint('ProductAdminSync error for ${p['sku']}: $e');
        failed++;
      }
    }

    return ProductAdminSyncResult(
      success: failed == 0,
      synced: synced,
      failed: failed,
    );
  }

  /// مزامنة منتج واحد
  static Future<bool> _syncOne(
    GraphQLClient client,
    Database db,
    Map<String, dynamic> product,
  ) async {
    final id = product['id'] as String?;
    if (id == null || id.isEmpty) return false;

    final variables = {
      'id': id,
      'cost': (product['standard_cost'] as num?)?.toDouble() ?? 0.0,
      'price': (product['sale_price'] as num?)?.toDouble() ?? 0.0,
    };

    final result = await client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: variables,
      ),
    );

    if (result.hasException) {
      final msg = result.exception.toString();
      // uniqeness/duplicate → المنتج موجود مسبقاً → نعتبره ناجحاً
      if (msg.contains('Uniqueness violation') ||
          msg.contains('duplicate key')) {
        await _markSynced(db, id);
        return true;
      }
      throw result.exception!;
    }

    await _markSynced(db, id);
    return true;
  }

  /// تعليم منتج كمُزامن
  static Future<void> _markSynced(Database db, String id) async {
    await db.update(
      'products_local',
      {'synced_at': DateTime.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// كم منتج في انتظار المزامنة؟
  static Future<int> countPending() async {
    final db = await LocalDatabase.instance.database;
    final r = await db.rawQuery(
      "SELECT COUNT(*) AS cnt FROM products_local "
      "WHERE synced_at IS NULL OR synced_at = ''",
    );
    if (r.isEmpty) return 0;
    return (r.first['cnt'] as int?) ?? 0;
  }
}
