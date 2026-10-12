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

  /// ظٹط¬ظ„ط¨ UUID ظ„ظ„ظˆط­ط¯ط© ط¨ظ†ط§ط،ظ‹ ط¹ظ„ظ‰ (product_id + unit_code)
  Future<SyncResult> syncPendingSessions(GraphQLClient client) async {
    final db = await LocalDatabase.instance.database;
    final pending = await db.query(
      'register_sessions_local',
      where: "synced_at IS NULL OR synced_at = ''",
      orderBy: 'opened_at ASC',
    );

    int synced = 0;
    int failed = 0;

    for (final session in pending) {
      try {
        await _syncOneSession(db, client, session);
        synced++;
      } catch (e) {
        failed++;
        debugPrint('Session sync failed for ${session['id']}: $e');
      }
    }

    return SyncResult(synced: synced, failed: failed, total: pending.length);
  }

  /// ط±ظپط¹ ط§ظ„ط¹ظ…ظ„ط§ط، ط§ظ„ط¬ط¯ط¯ (synced_at = NULL) ط¥ظ„ظ‰ Hasura
  Future<SyncResult> syncPendingCustomers(GraphQLClient client) async {
    final db = await LocalDatabase.instance.database;
    final pending = await db.query(
      'customers_local',
      where: "synced_at IS NULL OR synced_at = ''",
      orderBy: 'code ASC',
      limit: 100,
    );

    int synced = 0;
    int failed = 0;

    for (final customer in pending) {
      try {
        await _syncOneCustomer(db, client, customer);
        synced++;
      } catch (e) {
        failed++;
        debugPrint('Customer sync failed for ${customer['name']}: $e');
      }
    }

    return SyncResult(synced: synced, failed: failed, total: pending.length);
  }
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
    if (lines.isEmpty) throw Exception('ظ„ط§ طھظˆط¬ط¯ ط¨ظ†ظˆط¯ ظ„ظ„ظپط§طھظˆط±ط© $saleId');

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
        throw Exception('ط§ظ„ط³ط·ط± ط¨ظ„ط§ unit_code (ظپظˆط§طھظٹط± ظ‚ط¯ظٹظ…ط©طں)');
      }
      final key = productId + '|' + unitCode;
      final productUnitId = unitKeyMap[key];
      if (productUnitId == null) {
        throw Exception(
            'ظ„ط§ طھظˆط¬ط¯ ظˆط­ط¯ط© ظ…ط·ط§ط¨ظ‚ط© ظپظٹ Hasura: product=$productId unit=$unitCode');
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
        'paid_amount': sale['paid_amount'],
        if (sale['cashier_id'] != null)
          'cashier_id': sale['cashier_id'],
        'change_amount': sale['change_amount'],
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

  Future<void> _syncOneSession(
    Database db,
    GraphQLClient client,
    Map<String, dynamic> session,
  ) async {
    final sessionId = session['id'] as String;

    final mutation = gql(r"""
      mutation SyncSession($session: register_sessions_insert_input!) {
        insert_register_sessions_one(
          object: $session
          on_conflict: {
            constraint: register_sessions_pkey
            update_columns: [
              status, closed_at, closing_cash,
              expected_cash, difference, notes
            ]
          }
        ) {
          id
          status
        }
      }
    """);

    final variables = {
      'session': {
        'id': sessionId,
        'client_transaction_id': session['client_transaction_id'],
        'user_id': session['cashier_id'],
        'cash_register_id': session['cash_register_id'],
        'pos_device_id': session['pos_device_id'],
        'branch_id': session['branch_id'],
        'warehouse_id': session['warehouse_id'],
        'status': session['status'],
        'opened_at': session['opened_at'],
        'opening_cash': session['opening_cash'],
        if (session['closed_at'] != null) 'closed_at': session['closed_at'],
        if (session['closing_cash'] != null)
          'closing_cash': session['closing_cash'],
        if (session['expected_cash'] != null)
          'expected_cash': session['expected_cash'],
        if (session['difference'] != null) 'difference': session['difference'],
        if (session['notes'] != null) 'notes': session['notes'],
      },
    };

    final result = await client.mutate(
      MutationOptions(document: mutation, variables: variables),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    await db.update(
      'register_sessions_local',
      {'synced_at': DateTime.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> _syncOneCustomer(
    Database db,
    GraphQLClient client,
    Map<String, dynamic> customer,
  ) async {
    final id = customer['id'] as String;

    final mutation = gql(r"""
      mutation SyncCustomer($customer: customers_insert_input!) {
        insert_customers_one(
          object: $customer
          on_conflict: {
            constraint: customers_pkey
            update_columns: [
              code, name, name_foreign, id_code, index_number,
              phone, phone2, fax, email, address, po_box,
              activity_type, due_days, credit_limit, discount_percent,
              commission_percent, group_name, account_number, currency_code,
              payment_method, force_special_price, force_installment,
              notes, is_active
            ]
          }
        ) { id name }
      }
    """);

    final variables = {
      'customer': {
        'id': id,
        'code': customer['code'],
        'name': customer['name'],
        if (customer['name_foreign'] != null && (customer['name_foreign'] as String).isNotEmpty)
          'name_foreign': customer['name_foreign'],
        if (customer['id_code'] != null && (customer['id_code'] as String).isNotEmpty)
          'id_code': customer['id_code'],
        if (customer['index_number'] != null) 'index_number': customer['index_number'],
        if (customer['phone'] != null && (customer['phone'] as String).isNotEmpty)
          'phone': customer['phone'],
        if (customer['phone2'] != null && (customer['phone2'] as String).isNotEmpty)
          'phone2': customer['phone2'],
        if (customer['fax'] != null && (customer['fax'] as String).isNotEmpty)
          'fax': customer['fax'],
        if (customer['email'] != null && (customer['email'] as String).isNotEmpty)
          'email': customer['email'],
        if (customer['address'] != null && (customer['address'] as String).isNotEmpty)
          'address': customer['address'],
        if (customer['po_box'] != null && (customer['po_box'] as String).isNotEmpty)
          'po_box': customer['po_box'],
        'activity_type': customer['activity_type'] ?? 'retail',
        'due_days': customer['due_days'] ?? 0,
        'credit_limit': (customer['credit_limit'] as num?)?.toDouble() ?? 0,
        'discount_percent': (customer['discount_percent'] as num?)?.toDouble() ?? 0,
        'commission_percent': (customer['commission_percent'] as num?)?.toDouble() ?? 0,
        if (customer['group_name'] != null && (customer['group_name'] as String).isNotEmpty)
          'group_name': customer['group_name'],
        if (customer['account_number'] != null && (customer['account_number'] as String).isNotEmpty)
          'account_number': customer['account_number'],
        'currency_code': customer['currency_code'] ?? 'YER',
        'payment_method': customer['payment_method'] ?? 'cash',
        'force_special_price': ((customer['force_special_price'] as num?)?.toInt() ?? 0) == 1,
        'force_installment': ((customer['force_installment'] as num?)?.toInt() ?? 0) == 1,
        if (customer['notes'] != null && (customer['notes'] as String).isNotEmpty)
          'notes': customer['notes'],
        'is_active': ((customer['is_active'] as num?)?.toInt() ?? 1) == 1,
      },
    };

    final result = await client.mutate(
      MutationOptions(document: mutation, variables: variables),
    );

    if (result.hasException) {
      final msg = result.exception.toString();
      if (msg.contains('Uniqueness violation') || msg.contains('duplicate key')) {
        await _markCustomerSynced(db, id);
        return;
      }
      throw result.exception!;
    }

    await _markCustomerSynced(db, id);
  }

  Future<void> _markCustomerSynced(Database db, String customerId) async {
    await db.update(
      'customers_local',
      {'synced_at': DateTime.now().toUtc().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customerId],
    );
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
