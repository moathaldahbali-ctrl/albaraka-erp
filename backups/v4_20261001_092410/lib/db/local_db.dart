import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;
  final Random _rnd = Random();
  static const _uuid = Uuid();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final isDesktop = Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    String dbPath;
    if (isDesktop) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final dir = Directory(r'D:\albaraka\data');
      if (!await dir.exists()) { await dir.create(recursive: true); }
      dbPath = p.join(dir.path, 'albaraka_local.db');
    } else {
      dbPath = p.join(await sqflite.getDatabasesPath(), 'albaraka_local.db');
    }

    return openDatabase(
      dbPath,
      version: 9,
      onCreate: (db, version) async {
        await _createCurrenciesTable(db);
        await _createCategoriesTable(db);
        await _createProductsTable(db);
        await _createProductUnitsTable(db);
        await _createSalesTables(db);
        await _createDraftsTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) { await _createProductsTable(db); }
        if (oldVersion < 3) { await _createSalesTables(db); }
        if (oldVersion < 4) {
          await db.execute('ALTER TABLE products_local ADD COLUMN unit_id TEXT');
          await db.execute("ALTER TABLE sales_local ADD COLUMN branch_id TEXT");
          await db.execute("ALTER TABLE sales_local ADD COLUMN warehouse_id TEXT");
          await db.execute("ALTER TABLE sales_local ADD COLUMN customer_id TEXT");
          await db.execute("ALTER TABLE sales_local ADD COLUMN register_session_id TEXT");
          await db.execute("ALTER TABLE sales_local ADD COLUMN occurred_at TEXT");
        }
        if (oldVersion < 5) {
          await db.execute('DELETE FROM sale_lines_local');
          await db.execute('DELETE FROM sales_local');
        }
        if (oldVersion < 6) {
          await db.execute('ALTER TABLE products_local ADD COLUMN category_slug TEXT');
          await db.execute('ALTER TABLE products_local ADD COLUMN stock_qty REAL');
        }
        if (oldVersion < 7) {
          await _createProductUnitsTable(db);
          await db.execute('ALTER TABLE sale_lines_local ADD COLUMN product_unit_id TEXT');
          await db.execute('ALTER TABLE sale_lines_local ADD COLUMN unit_code TEXT');
          await db.execute('ALTER TABLE sale_lines_local ADD COLUMN conversion_factor REAL');
          await db.execute("ALTER TABLE sales_local ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'cash'");
          await db.execute('ALTER TABLE sales_local ADD COLUMN customer_name TEXT');
        }
        if (oldVersion < 8) { await _createCategoriesTable(db); }
        if (oldVersion < 9) { await _createDraftsTable(db); }
      },
    );
  }

  Future<void> _createCurrenciesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS currencies_local (
        id TEXT PRIMARY KEY, code TEXT NOT NULL, name TEXT NOT NULL,
        exchange_rate REAL NOT NULL, synced_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories_local (
        slug TEXT PRIMARY KEY, name TEXT NOT NULL, synced_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products_local (
        id TEXT PRIMARY KEY, name TEXT NOT NULL, sku TEXT,
        standard_cost REAL NOT NULL, sale_price REAL NOT NULL,
        unit_id TEXT, category_slug TEXT, stock_qty REAL,
        synced_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createProductUnitsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS product_units_local (
        id TEXT PRIMARY KEY, product_id TEXT NOT NULL,
        unit_code TEXT NOT NULL, conversion_factor REAL NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0, synced_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_pu_product ON product_units_local(product_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_pu_default ON product_units_local(product_id, is_default)');
  }

  Future<void> _createSalesTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sales_local (
        id TEXT PRIMARY KEY, invoice_number TEXT NOT NULL UNIQUE,
        client_transaction_id TEXT NOT NULL, total REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending', branch_id TEXT,
        warehouse_id TEXT, customer_id TEXT, register_session_id TEXT,
        occurred_at TEXT, created_at TEXT NOT NULL, synced_at TEXT,
        payment_method TEXT NOT NULL DEFAULT 'cash', customer_name TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sale_lines_local (
        id TEXT PRIMARY KEY, sale_id TEXT NOT NULL, product_id TEXT NOT NULL,
        product_name TEXT NOT NULL, quantity REAL NOT NULL,
        unit_price REAL NOT NULL, subtotal REAL NOT NULL,
        product_unit_id TEXT, unit_code TEXT, conversion_factor REAL,
        FOREIGN KEY (sale_id) REFERENCES sales_local (id)
      )
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sales_status ON sales_local(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_lines_sale_id ON sale_lines_local(sale_id)');
  }

  Future<void> _createDraftsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS drafts_local (
        key TEXT PRIMARY KEY, value TEXT NOT NULL, updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<int> countPendingSales() async {
    final db = await database;
    final r = await db.rawQuery("SELECT COUNT(*) as c FROM sales_local WHERE status = 'pending'");
    return (r.first['c'] as int?) ?? 0;
  }

  Future<void> upsertCurrencies(List<Map<String, dynamic>> currencies) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final c in currencies) {
      batch.insert('currencies_local', {
        'id': c['id'], 'code': c['code'], 'name': c['name'],
        'exchange_rate': (c['exchange_rate'] as num).toDouble(),
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertCategories(List<Map<String, dynamic>> categories) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final c in categories) {
      batch.insert('categories_local', {
        'slug': c['slug'], 'name': c['name'], 'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertProducts(List<Map<String, dynamic>> products) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final p in products) {
      batch.insert('products_local', {
        'id': p['id'], 'name': p['name'], 'sku': p['sku'],
        'standard_cost': (p['standard_cost'] as num).toDouble(),
        'sale_price': (p['sale_price'] as num).toDouble(),
        'unit_id': p['unit_id'], 'category_slug': p['category_slug'],
        'stock_qty': p['stock_qty'] == null ? null : (p['stock_qty'] as num).toDouble(),
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> upsertProductUnits(List<Map<String, dynamic>> units) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final u in units) {
      batch.insert('product_units_local', {
        'id': u['id'], 'product_id': u['product_id'],
        'unit_code': u['unit_code'],
        'conversion_factor': (u['conversion_factor'] as num).toDouble(),
        'is_default': (u['is_default'] == true) ? 1 : 0,
        'synced_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getProductUnits(String productId) async {
    final db = await database;
    return db.query('product_units_local',
      where: 'product_id = ?', whereArgs: [productId],
      orderBy: 'conversion_factor ASC');
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    final db = await database;
    final r = await db.query('products_local',
      where: 'id = ?', whereArgs: [id], limit: 1);
    return r.isEmpty ? null : r.first;
  }

  Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    final db = await database;
    return db.query('currencies_local', orderBy: 'code ASC');
  }

  Future<List<Map<String, dynamic>>> getUsedCategories() async {
    final db = await database;
    return db.rawQuery('''
      SELECT p.category_slug AS slug, c.name AS name, COUNT(*) AS cnt
      FROM products_local p
      LEFT JOIN categories_local c ON c.slug = p.category_slug
      WHERE p.category_slug IS NOT NULL
      GROUP BY p.category_slug
      ORDER BY c.name ASC
    ''');
  }

  Future<List<Map<String, dynamic>>> searchProducts(
    String query, {String? categorySlug}) async {
    final db = await database;
    final trimmed = query.trim();
    final whereParts = <String>[];
    final args = <dynamic>[];

    if (categorySlug != null && categorySlug.isNotEmpty) {
      whereParts.add('category_slug = ?');
      args.add(categorySlug);
    }
    if (trimmed.isNotEmpty) {
      whereParts.add('(name LIKE ? OR sku LIKE ?)');
      final q = '%' + trimmed + '%';
      args.add(q); args.add(q);
    }
    final baseWhere = whereParts.isEmpty ? null : whereParts.join(' AND ');
    final baseArgs = args.isEmpty ? null : args;

    if (trimmed.isNotEmpty) {
      final exactWhere = <String>[];
      final exactArgs = <dynamic>[];
      if (categorySlug != null && categorySlug.isNotEmpty) {
        exactWhere.add('category_slug = ?'); exactArgs.add(categorySlug);
      }
      exactWhere.add('sku = ?'); exactArgs.add(trimmed);

      final exact = await db.query('products_local',
        where: exactWhere.join(' AND '), whereArgs: exactArgs, limit: 1);
      if (exact.isNotEmpty) {
        final rest = await db.query('products_local',
          where: baseWhere == null ? 'sku != ?' : '($baseWhere) AND sku != ?',
          whereArgs: baseArgs == null ? [trimmed] : [...baseArgs, trimmed],
          orderBy: 'name ASC', limit: 49);
        return [...exact, ...rest];
      }
    }
    return db.query('products_local',
      where: baseWhere, whereArgs: baseArgs,
      orderBy: 'name ASC', limit: 50);
  }

  // ============ Drafts ============
  Future<void> saveDraft(String key, Map<String, dynamic> value) async {
    final db = await database;
    await db.insert('drafts_local', {
      'key': key,
      'value': jsonEncode(value),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> loadDraft(String key) async {
    final db = await database;
    final r = await db.query('drafts_local',
      where: 'key = ?', whereArgs: [key], limit: 1);
    if (r.isEmpty) return null;
    try {
      final raw = r.first['value'] as String;
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearDraft(String key) async {
    final db = await database;
    await db.delete('drafts_local', where: 'key = ?', whereArgs: [key]);
  }

  Future<String> _generateInvoiceNumber() async {
    final db = await database;
    final now = DateTime.now();
    final ymd = now.year.toString().padLeft(4, '0') +
        now.month.toString().padLeft(2, '0') +
        now.day.toString().padLeft(2, '0');
    final prefix = 'LOCAL-' + ymd + '-';
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM sales_local WHERE invoice_number LIKE ?',
      [prefix + '%']);
    final count = (r.first['c'] as int?) ?? 0;
    return prefix + (count + 1).toString().padLeft(4, '0');
  }

  String _newId(String prefix) => _uuid.v4();

  Future<Map<String, dynamic>> saveInvoice({
    required List<Map<String, dynamic>> items,
    required double total,
    String paymentMethod = 'cash',
    String? customerName,
  }) async {
    if (items.isEmpty) throw Exception('الفاتورة فارغة');
    final db = await database;
    final now = DateTime.now();
    final invoiceNumber = await _generateInvoiceNumber();
    final saleId = _newId('sale');
    final clientTxId = _newId('tx');

    await db.transaction((txn) async {
      await txn.insert('sales_local', {
        'id': saleId, 'invoice_number': invoiceNumber,
        'client_transaction_id': clientTxId, 'total': total,
        'status': 'pending',
        'branch_id': '11111111-1111-1111-1111-111111111111',
        'warehouse_id': '33333333-3333-3333-3333-333333333333',
        'customer_id': '77777777-7777-7777-7777-777777777777',
        'register_session_id': '44444444-4444-4444-4444-444444444444',
        'occurred_at': now.toUtc().toIso8601String(),
        'created_at': now.toIso8601String(),
        'synced_at': null,
        'payment_method': paymentMethod,
        'customer_name': customerName,
      });
      for (final it in items) {
        await txn.insert('sale_lines_local', {
          'id': _newId('line'), 'sale_id': saleId,
          'product_id': it['product_id'], 'product_name': it['product_name'],
          'quantity': it['quantity'], 'unit_price': it['unit_price'],
          'subtotal': it['subtotal'],
          'product_unit_id': it['product_unit_id'],
          'unit_code': it['unit_code'],
          'conversion_factor': it['conversion_factor'],
        });
      }
    });

    return {'id': saleId, 'invoice_number': invoiceNumber, 'total': total};
  }
}
