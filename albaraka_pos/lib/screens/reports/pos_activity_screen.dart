import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../db/local_db.dart';

/// v8.3.4 — تقرير حركة نقاط البيع
class PosActivityScreen extends StatefulWidget {
  const PosActivityScreen({super.key});

  @override
  State<PosActivityScreen> createState() => _PosActivityScreenState();
}

enum _Period { today, week, session }

class _PosActivityScreenState extends State<PosActivityScreen> {
  _Period _period = _Period.today;
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  double _sumCash = 0;
  double _sumCredit = 0;
  int _countCash = 0;
  int _countCredit = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    String where = '';
    final now = DateTime.now();
    if (_period == _Period.today) {
      final start = DateTime(now.year, now.month, now.day).toIso8601String();
      where = "AND occurred_at >= '$start'";
    } else if (_period == _Period.week) {
      final start = now.subtract(const Duration(days: 7)).toIso8601String();
      where = "AND occurred_at >= '$start'";
    } else if (_period == _Period.session) {
      final session = await LocalDatabase.instance.getActiveSession();
      if (session != null) {
        final sid = session['id'] as String;
        where = "AND register_session_id = '$sid'";
      } else {
        where = "AND 1=0";
      }
    }

    final db = await LocalDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT s.invoice_number, s.occurred_at, s.total, s.payment_method,
             s.customer_name, u.display_name AS cashier_name
      FROM sales_local s
      LEFT JOIN users_local u ON u.id = s.cashier_id
      WHERE 1=1 $where
      ORDER BY s.occurred_at DESC
      LIMIT 500
    ''');

    double cash = 0, credit = 0;
    int cCash = 0, cCredit = 0;
    for (final r in rows) {
      final t = (r['total'] as num?)?.toDouble() ?? 0;
      if ((r['payment_method'] as String?) == 'credit') {
        credit += t;
        cCredit++;
      } else {
        cash += t;
        cCash++;
      }
    }

    if (!mounted) return;
    setState(() {
      _rows = rows;
      _sumCash = cash;
      _sumCredit = credit;
      _countCash = cCash;
      _countCredit = cCredit;
      _loading = false;
    });
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  String _fmtTime(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('HH:mm').format(d);
  }

  String _fmtDate(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('yyyy/MM/dd').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حركة نقاط البيع'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _load,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilter(theme),
            _buildSummary(theme),
            const Divider(height: 1),
            Expanded(child: _buildTable(theme)),
          ],
        ),
      ),
    );
  }

  // ---------- فلترة ----------
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
              ButtonSegment(value: _Period.session, label: Text('الوردية')),
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

  // ---------- إحصاء ----------
  Widget _buildSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _statCard(theme, 'فواتير نقد',
              '$_countCash', _fmtNum(_sumCash), Colors.green),
          const SizedBox(width: 8),
          _statCard(theme, 'فواتير آجل',
              '$_countCredit', _fmtNum(_sumCredit), Colors.orange),
          const SizedBox(width: 8),
          _statCard(theme, 'الإجمالي',
              '${_rows.length}', _fmtNum(_sumCash + _sumCredit), theme.colorScheme.primary),
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
            Text(title, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('$amount YER', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  // ---------- الجدول ----------
  Widget _buildTable(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_rows.isEmpty) {
      return const Center(child: Text('لا توجد فواتير في هذه الفترة'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 36,
          dataRowMaxHeight: 40,
          columns: const [
            DataColumn(label: Text('رقم الفاتورة')),
            DataColumn(label: Text('التاريخ')),
            DataColumn(label: Text('الوقت')),
            DataColumn(label: Text('الكاشير')),
            DataColumn(label: Text('الدفع')),
            DataColumn(label: Text('الإجمالي')),
          ],
          rows: _rows.map((r) {
            final pay = (r['payment_method'] as String?) ?? 'cash';
            final payLabel = pay == 'credit' ? 'آجل' : 'نقد';
            final payColor = pay == 'credit' ? Colors.orange : Colors.green;
            return DataRow(cells: [
              DataCell(Text(
                (r['invoice_number'] as String?) ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
              DataCell(Text(_fmtDate(r['occurred_at'] as String?), style: const TextStyle(fontSize: 12))),
              DataCell(Text(_fmtTime(r['occurred_at'] as String?), style: const TextStyle(fontSize: 12))),
              DataCell(Text((r['cashier_name'] as String?) ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: payColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(payLabel, style: TextStyle(fontSize: 11, color: payColor, fontWeight: FontWeight.bold)),
              )),
              DataCell(Text(
                _fmtNum((r['total'] as num?) ?? 0),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}