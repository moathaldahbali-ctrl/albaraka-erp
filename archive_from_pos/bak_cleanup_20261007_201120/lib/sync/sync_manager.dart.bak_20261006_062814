import 'package:flutter/foundation.dart';
import 'package:graphql/client.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../db/local_db.dart';

class SyncResult {
  final int synced;
  final int failed;
  final int total;
  SyncResult({required this.synced, required this.failed, required this.total});
}

class SyncManager {
  SyncManager._();
  static final SyncManager instance = SyncManager._();

  Future<SyncResult> syncPendingSales(GraphQLClient client) async {
    final db = await LocalDatabase.instance.database;
    final pending = await db.query(
      'sales_local',
      where: "status = 'pending'",
      orderBy: 'created_at ASC',
    );

    int synced = 0;
    int failed = 0;

    for (final sale in pending) {
      try {
        await _syncOne(db, client, sale);
        synced++;
      } catch (e) {
        failed++;
        debugPrint('Sync failed for ${sale['invoice_number']}: $e');
      }
    }

    return SyncResult(synced: synced, failed: failed, total: pending.length);
  }

  /// يجلب UUID للوحدة بناءً على (product_id + unit_code)
  Future<Map<String, String>> _lookupUnitKeys(
    GraphQLClient client,
    List<String> productIds,
  ) async {
    if (productIds.isEmpty) return {};

    final q = gql(r'''
      query GetUnits($ids: [uuid!]!) {
        product_units(where: {product_id: {_in: $ids}}) {
          id
          product_id
          unit_code
        }
      }
    ''');

    final result = await client.query(
      QueryOptions(document: q, variables: {'ids': productIds}),
    );
    if (result.hasException) {
      throw Exception('product_units lookup failed: ${result.exception}');
    }

    final rows = (result.data?['product_units'] as List<dynamic>? ?? []);
    final map = <String, String>{};
    for (final r in rows) {
      final key = (r['product_id'] as String) + '|' + (r['unit_code'] as String);
      map[key] = r['id'] as String;
    }
    return map;
  }

  Future<void> _syncOne(
    Database db,
    GraphQLClient client,
    Map<String, dynamic> sale,
  ) async {
    final saleId = sale['id'] as String;

    final lines = await db.query(
      'sale_lines_local',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    if (lines.isEmpty) throw Exception('لا توجد بنود للفاتورة $saleId');

    final productIds = <String>{};
    for (final line in lines) {
      productIds.add(line['product_id'] as String);
    }

    final unitKeyMap = await _lookupUnitKeys(client, productIds.toList());

    final lineInputs = <Map<String, dynamic>>[];
    for (final line in lines) {
      final productId = line['product_id'] as String;
      final unitCode = line['unit_code'] as String?;
      if (unitCode == null) {
        throw Exception('السطر بلا unit_code (فواتير قديمة؟)');
      }
      final key = productId + '|' + unitCode;
      final productUnitId = unitKeyMap[key];
      if (productUnitId == null) {
        throw Exception(
            'لا توجد وحدة مطابقة في Hasura: product=$productId unit=$unitCode');
      }

      lineInputs.add({
        'id': line['id'],
        'product_id': productId,
        'product_unit_id': productUnitId,
        'quantity': line['quantity'],
        'unit_price': line['unit_price'],
        'subtotal': line['subtotal'],
      });
    }

    final clientTxId = sale['client_transaction_id'] as String;

    final mutation = gql(r'''
      mutation SyncSale($sale: sales_insert_input!) {
        insert_sales_one(object: $sale) {
          id
          invoice_number
        }
      }
    ''');

    final variables = {
      'sale': {
        'id': sale['id'],
        'branch_id': sale['branch_id'],
        'warehouse_id': sale['warehouse_id'],
        'customer_id': sale['customer_id'],
        'register_session_id': sale['register_session_id'],
        'occurred_at': sale['occurred_at'],
        'invoice_number': sale['invoice_number'],
        'total': sale['total'],
        'payment_method': sale['payment_method'] ?? 'cash',
        if (sale['customer_name'] != null)
          'customer_name': sale['customer_name'],
        'economic_event_registry': {
          'data': {
            'client_transaction_id': clientTxId,
            'event_type': 'SALE',
          },
          'on_conflict': {
            'constraint': 'economic_event_registry_pkey',
            'update_columns': ['event_type'],
          },
        },
        'sale_lines': {'data': lineInputs},
      },
    };

    final result = await client.mutate(
      MutationOptions(document: mutation, variables: variables),
    );

    if (result.hasException) {
      final msg = result.exception.toString();
      if (msg.contains('Uniqueness violation') ||
          msg.contains('duplicate key')) {
        await _markSynced(db, saleId);
        return;
      }
      throw result.exception!;
    }

    await _markSynced(db, saleId);
  }

  Future<void> _markSynced(Database db, String saleId) async {
    await db.update(
      'sales_local',
      {
        'status': 'synced',
        'synced_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }
}
