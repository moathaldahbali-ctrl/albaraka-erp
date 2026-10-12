import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../db/local_db.dart';

/// v8.3.6 — تقرير حركة العملاء
class CustomerActivityScreen extends StatefulWidget {
  const CustomerActivityScreen({super.key});

  @override
  State<CustomerActivityScreen> createState() => _CustomerActivityScreenState();
}

enum _Period { today, week, month }

class _CustomerActivityScreenState extends State<CustomerActivityScreen> {
  _Period _period = _Period.month;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  double _sumCash = 0;
  double _sumCredit = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    String where = '';
    final now = DateTime.now();
    if (_period == _Period.today) {
      final start = DateTime(now.year, now.month, now.day).toIso8601String();
      where = "AND s.occurred_at >= '$start'";
    } else if (_period == _Period.week) {
      final start = now.subtract(const Duration(days: 7)).toIso8601String();
      where = "AND s.occurred_at >= '$start'";
    } else {
      final start = now.subtract(const Duration(days: 30)).toIso8601String();
      where = "AND s.occurred_at >= '$start'";
    }

    String searchWhere = '';
    if (_search.trim().isNotEmpty) {
      final s = _search.trim().replaceAll("'", "''");
      searchWhere = "AND (c.name LIKE '%$s%' OR c.phone LIKE '%$s%' OR c.code LIKE '%$s%')";
    }

    final db = await LocalDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.phone, c.code, c.credit_limit,
             COUNT(s.id) AS sales_count,
             COALESCE(SUM(CASE WHEN s.payment_method = 'cash' THEN s.total ELSE 0 END), 0) AS cash_total,
             COALESCE(SUM(CASE WHEN s.payment_method = 'credit' THEN s.total ELSE 0 END), 0) AS credit_total,
             COALESCE(SUM(s.total), 0) AS total,
             MAX(s.occurred_at) AS last_sale
      FROM customers_local c
      LEFT JOIN sales_local s ON s.customer_id = c.id $where
      WHERE c.code != 'WALKIN' $searchWhere
      GROUP BY c.id
      ORDER BY total DESC, c.name ASC
      LIMIT 500
    ''');

    double sumCash = 0, sumCredit = 0;
    for (final r in rows) {
      sumCash += (r['cash_total'] as num?)?.toDouble() ?? 0;
      sumCredit += (r['credit_total'] as num?)?.toDouble() ?? 0;
    }

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _sumCash = sumCash;
      _sumCredit = sumCredit;
      _loading = false;
    });
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  String _fmtDate(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('MM/dd').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حركة العملاء'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'تحديث'),
          ],
        ),
        body: Column(
          children: [
            _buildFilter(theme),
            _buildSearch(theme),
            _buildSummary(theme),
            const Divider(height: 1),
            Expanded(child: _buildTable(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Text('الفترة:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          SegmentedButton<_Period>(
            segments: const [
              ButtonSegment(value: _Period.today, label: Text('اليوم')),
              ButtonSegment(value: _Period.week, label: Text('7 أيام')),
              ButtonSegment(value: _Period.month, label: Text('30 يوم')),
            ],
            selected: {_period},
            onSelectionChanged: (s) {
              setState(() => _period = s.first);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'بحث بالاسم أو الهاتف أو الرقم',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _search = '');
                    _load();
                  },
                )
              : null,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: (v) {
          setState(() => _search = v);
          _load();
        },
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _statCard(theme, 'عملاء نشطون', '${_rows.where((r) => ((r['total'] as num?)?.toDouble() ?? 0) > 0).length}', '', Colors.blue),
          const SizedBox(width: 8),
          _statCard(theme, 'إجمالي النقد', '', _fmtNum(_sumCash), Colors.green),
          const SizedBox(width: 8),
          _statCard(theme, 'إجمالي الآجل', '', _fmtNum(_sumCredit), Colors.orange),
          const SizedBox(width: 8),
          _statCard(theme, 'الإجمالي', '', _fmtNum(_sumCash + _sumCredit), theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String title, String count, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (count.isNotEmpty)
              Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (amount.isNotEmpty)
              Text('$amount YER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_rows.isEmpty) return const Center(child: Text('لا توجد بيانات في هذه الفترة'));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          columns: const [
            DataColumn(label: Text('العميل')),
            DataColumn(label: Text('الهاتف')),
            DataColumn(label: Text('فواتير')),
            DataColumn(label: Text('نقد')),
            DataColumn(label: Text('آجل')),
            DataColumn(label: Text('الإجمالي')),
            DataColumn(label: Text('آخر فاتورة')),
          ],
          rows: _rows.map((r) {
            final credit = (r['credit_total'] as num?)?.toDouble() ?? 0;
            return DataRow(cells: [
              DataCell(Text(
                (r['name'] as String?) ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
              DataCell(Text((r['phone'] as String?) ?? '-', style: const TextStyle(fontSize: 11))),
              DataCell(Text(
                '${(r['sales_count'] as num?)?.toInt() ?? 0}',
                style: const TextStyle(fontSize: 12),
              )),
              DataCell(Text(_fmtNum((r['cash_total'] as num?) ?? 0), style: const TextStyle(fontSize: 12))),
              DataCell(Text(
                _fmtNum(credit),
                style: TextStyle(
                  fontSize: 12,
                  color: credit > 0 ? Colors.orange : null,
                  fontWeight: credit > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              )),
              DataCell(Text(
                _fmtNum((r['total'] as num?) ?? 0),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
              DataCell(Text(_fmtDate(r['last_sale'] as String?), style: const TextStyle(fontSize: 11))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}