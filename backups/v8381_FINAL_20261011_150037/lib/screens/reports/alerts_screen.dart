import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../db/local_db.dart';

/// v8.3.9b — لوحة التنبيهات الموحّدة
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = true;

  List<Map<String, dynamic>> _zero = [];
  List<Map<String, dynamic>> _low = [];
  List<Map<String, dynamic>> _idle = [];
  List<Map<String, dynamic>> _debt = [];

  static const int kLowThreshold = 10;
  static const int kIdleDays = 90;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = await LocalDatabase.instance.database;

    // 1) نفد
    _zero = await db.rawQuery('''
      SELECT sku, name, category_slug, unit_id, stock_qty,
             standard_cost, sale_price
      FROM products_local
      WHERE stock_qty <= 0
      ORDER BY name ASC
      LIMIT 500
    ''');

    // 2) منخفض
    _low = await db.rawQuery('''
      SELECT sku, name, category_slug, unit_id, stock_qty,
             standard_cost, sale_price
      FROM products_local
      WHERE stock_qty > 0 AND stock_qty < $kLowThreshold
      ORDER BY stock_qty ASC, name ASC
      LIMIT 500
    ''');

    // 3) راكد (لم يُبَع منذ 90 يوم)
    final cutoff =
        DateTime.now().subtract(const Duration(days: kIdleDays)).toIso8601String();
    _idle = await db.rawQuery('''
      SELECT p.sku, p.name, p.category_slug, p.unit_id, p.stock_qty,
             (SELECT MAX(s.occurred_at) FROM sale_lines_local sl
              JOIN sales_local s ON s.id = sl.sale_id
              WHERE sl.product_id = p.id) AS last_sale
      FROM products_local p
      WHERE p.stock_qty > 0
        AND (SELECT MAX(s.occurred_at) FROM sale_lines_local sl
             JOIN sales_local s ON s.id = sl.sale_id
             WHERE sl.product_id = p.id) < '$cutoff'
         OR (SELECT MAX(s.occurred_at) FROM sale_lines_local sl
             JOIN sales_local s ON s.id = sl.sale_id
             WHERE sl.product_id = p.id) IS NULL
      ORDER BY last_sale ASC
      LIMIT 500
    ''');

    // 4) ديون (عملاء آجل > حدهم)
    _debt = await db.rawQuery('''
      SELECT c.name, c.phone, c.credit_limit,
             COALESCE(SUM(CASE WHEN s.payment_method = 'credit' THEN s.total ELSE 0 END), 0) AS credit_total,
             COUNT(s.id) AS sales_count
      FROM customers_local c
      LEFT JOIN sales_local s ON s.customer_id = c.id
      WHERE c.code != 'WALKIN'
      GROUP BY c.id
      HAVING credit_total > 0
      ORDER BY credit_total DESC
      LIMIT 500
    ''');

    if (mounted) setState(() => _loading = false);
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  String _fmtDate(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('yyyy/MM/dd').format(d);
  }

  int _daysAgo(String? iso) {
    if (iso == null) return 9999;
    final d = DateTime.tryParse(iso);
    if (d == null) return 9999;
    return DateTime.now().difference(d).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التنبيهات'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'تحديث'),
          ],
          bottom: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabs: [
              Tab(text: 'نفد (${_zero.length})', icon: const Icon(Icons.error_outline, size: 18)),
              Tab(text: 'منخفض (${_low.length})', icon: const Icon(Icons.warning_amber, size: 18)),
              Tab(text: 'راكد (${_idle.length})', icon: const Icon(Icons.hourglass_empty, size: 18)),
              Tab(text: 'ديون (${_debt.length})', icon: const Icon(Icons.account_balance_wallet, size: 18)),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildZeroTab(theme),
                  _buildLowTab(theme),
                  _buildIdleTab(theme),
                  _buildDebtTab(theme),
                ],
              ),
      ),
    );
  }

  // ===== Tab 1: Zero =====
  Widget _buildZeroTab(ThemeData theme) {
    if (_zero.isEmpty) {
      return _emptyState('لا توجد أصناف نفدت ✓', Colors.green);
    }
    return _dataTable(
      columns: const ['SKU', 'الصنف', 'وحدة', 'رصيد', 'سعر البيع'],
      rows: _zero.map((r) => [
        _txt((r['sku'] as String?) ?? '-', mono: true, gray: true),
        _txt((r['name'] as String?) ?? '-', bold: true),
        _txt((r['unit_id'] as String?) ?? '-'),
        _txtNum(_fmtNum((r['stock_qty'] as num?) ?? 0), color: Colors.red),
        _txtNum(_fmtNum((r['sale_price'] as num?) ?? 0)),
      ]).toList(),
      bgColor: Colors.red.withValues(alpha: 0.03),
    );
  }

  // ===== Tab 2: Low =====
  Widget _buildLowTab(ThemeData theme) {
    if (_low.isEmpty) {
      return _emptyState('لا توجد أصناف منخفضة ✓', Colors.green);
    }
    return _dataTable(
      columns: const ['SKU', 'الصنف', 'وحدة', 'رصيد', 'سعر البيع'],
      rows: _low.map((r) {
        final qty = (r['stock_qty'] as num?)?.toDouble() ?? 0;
        return [
          _txt((r['sku'] as String?) ?? '-', mono: true, gray: true),
          _txt((r['name'] as String?) ?? '-', bold: true),
          _txt((r['unit_id'] as String?) ?? '-'),
          _txtNum(_fmtNum(qty), color: Colors.orange),
          _txtNum(_fmtNum((r['sale_price'] as num?) ?? 0)),
        ];
      }).toList(),
      bgColor: Colors.orange.withValues(alpha: 0.03),
    );
  }

  // ===== Tab 3: Idle =====
  Widget _buildIdleTab(ThemeData theme) {
    if (_idle.isEmpty) {
      return _emptyState('لا توجد أصناف راكدة ✓', Colors.green);
    }
    return _dataTable(
      columns: const ['SKU', 'الصنف', 'رصيد', 'آخر بيع', 'منذ'],
      rows: _idle.map((r) {
        final days = _daysAgo(r['last_sale'] as String?);
        return [
          _txt((r['sku'] as String?) ?? '-', mono: true, gray: true),
          _txt((r['name'] as String?) ?? '-', bold: true),
          _txtNum(_fmtNum((r['stock_qty'] as num?) ?? 0)),
          _txt(_fmtDate(r['last_sale'] as String?)),
          _txtNum(
            days > 999 ? 'أبداً' : '$days يوم',
            color: days > 180 ? Colors.red : (days > 120 ? Colors.orange : Colors.grey),
          ),
        ];
      }).toList(),
      bgColor: Colors.yellow.withValues(alpha: 0.03),
    );
  }

  // ===== Tab 4: Debt =====
  Widget _buildDebtTab(ThemeData theme) {
    if (_debt.isEmpty) {
      return _emptyState('لا توجد ديون على العملاء ✓', Colors.green);
    }
    return _dataTable(
      columns: const ['العميل', 'الهاتف', 'فواتير', 'الحد', 'المديونية'],
      rows: _debt.map((r) {
        final credit = (r['credit_total'] as num?)?.toDouble() ?? 0;
        final limit = (r['credit_limit'] as num?)?.toDouble() ?? 0;
        final over = limit > 0 && credit > limit;
        return [
          _txt((r['name'] as String?) ?? '-', bold: true),
          _txt((r['phone'] as String?) ?? '-'),
          _txtNum('${(r['sales_count'] as num?)?.toInt() ?? 0}'),
          _txtNum(limit == 0 ? 'غير محدود' : _fmtNum(limit)),
          _txtNum(
            _fmtNum(credit),
            color: over ? Colors.red : Colors.orange,
            bold: true,
          ),
        ];
      }).toList(),
      bgColor: Colors.blue.withValues(alpha: 0.03),
    );
  }

  // ===== Helpers =====
  Widget _emptyState(String msg, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: color.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(fontSize: 15, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _dataTable({
    required List<String> columns,
    required List<List<Widget>> rows,
    Color? bgColor,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 30,
          dataRowMaxHeight: 36,
          horizontalMargin: 12,
          columnSpacing: 14,
          headingRowColor: WidgetStatePropertyAll(bgColor),
          columns: columns
              .map((c) => DataColumn(label: Text(c, style: const TextStyle(fontSize: 12))))
              .toList(),
          rows: rows.map((cells) => DataRow(cells: cells.map((w) => DataCell(w)).toList())).toList(),
        ),
      ),
    );
  }

  Widget _txt(String s, {bool mono = false, bool gray = false, bool bold = false}) {
    return Text(
      s,
      style: TextStyle(
        fontSize: 11,
        fontFamily: mono ? 'monospace' : null,
        color: gray ? Colors.grey : null,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _txtNum(String s, {Color? color, bool bold = false}) {
    return Text(
      s,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.bold : FontWeight.w600,
        color: color ?? Colors.black87,
      ),
    );
  }
}