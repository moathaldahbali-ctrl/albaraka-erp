import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../db/local_db.dart';

/// v8.3.9a — الأصناف المنتهية (نفدت من المخزون)
class ExpiredProductsScreen extends StatefulWidget {
  const ExpiredProductsScreen({super.key});

  @override
  State<ExpiredProductsScreen> createState() => _ExpiredProductsScreenState();
}

class _ExpiredProductsScreenState extends State<ExpiredProductsScreen> {
  List<Map<String, dynamic>> _rows = [];
  List<Map<String, dynamic>> _categories = [];
  Map<String, String> _catNames = {};
  bool _loading = true;
  String _categoryFilter = '';
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final db = await LocalDatabase.instance.database;
    try {
      final cats = await db.rawQuery(
          "SELECT slug, name FROM categories_local ORDER BY name ASC");
      for (final c in cats) {
        _catNames[(c['slug'] as String?) ?? ''] = (c['name'] as String?) ?? '';
      }
      final used = await db.rawQuery('''
        SELECT DISTINCT category_slug FROM products_local
        WHERE category_slug IS NOT NULL AND category_slug != ''
        ORDER BY category_slug ASC
      ''');
      _categories = used.map((r) {
        final slug = r['category_slug'] as String? ?? '';
        return <String, dynamic>{
          'slug': slug,
          'name': _catNames[slug] ?? slug,
        };
      }).toList();
    } catch (_) {
      _categories = [];
    }
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    String catWhere = '';
    if (_categoryFilter.isNotEmpty) {
      final safe = _categoryFilter.replaceAll("'", "''");
      catWhere = "AND category_slug = '$safe'";
    }

    String searchWhere = '';
    if (_search.trim().isNotEmpty) {
      final s = _search.trim().replaceAll("'", "''");
      searchWhere = "AND (name LIKE '%$s%' OR sku LIKE '%$s%')";
    }

    final db = await LocalDatabase.instance.database;
    final rows = await db.rawQuery('''
      SELECT id, sku, name, category_slug, unit_id, stock_qty,
             standard_cost, sale_price,
             (SELECT MAX(s.occurred_at) FROM sale_lines_local sl
              JOIN sales_local s ON s.id = sl.sale_id
              WHERE sl.product_id = products_local.id) AS last_sale
      FROM products_local
      WHERE stock_qty <= 0 $catWhere $searchWhere
      ORDER BY name ASC
      LIMIT 1000
    ''');

    if (mounted) {
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  String _fmtDate(String? iso) {
    if (iso == null) return '-';
    final d = DateTime.tryParse(iso);
    if (d == null) return '-';
    return DateFormat('MM/dd').format(d);
  }

  String _catLabel(String? slug) {
    if (slug == null || slug.isEmpty) return '-';
    return _catNames[slug] ?? slug;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الأصناف المنتهية'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'تحديث'),
          ],
        ),
        body: Column(
          children: [
            _buildSummary(theme),
            _buildFilters(theme),
            const Divider(height: 1),
            Expanded(child: _buildTable(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _statCard(theme, 'أصناف نفدت', '${_rows.length}', Colors.red),
          const SizedBox(width: 8),
          _statCard(theme, 'تصنيفات متأثرة',
              '${_rows.map((r) => r['category_slug']).toSet().length}', Colors.orange),
          const SizedBox(width: 8),
          _statCard(theme, 'إجمالي القيمة المفقودة',
              _fmtNum(_rows.fold<double>(0, (s, r) => s + ((r['sale_price'] as num?)?.toDouble() ?? 0))),
              theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String title, String value, Color color) {
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
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: _categoryFilter,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'التصنيف',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              items: [
                const DropdownMenuItem(value: '', child: Text('كل المجموعات')),
                ..._categories.map((c) => DropdownMenuItem(
                      value: c['slug'] as String,
                      child: Text(c['name'] as String),
                    )),
              ],
              onChanged: (v) {
                setState(() => _categoryFilter = v ?? '');
                _load();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم أو SKU',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade300),
            const SizedBox(height: 12),
            const Text('لا توجد أصناف منتهية ✓',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 30,
          dataRowMaxHeight: 36,
          horizontalMargin: 12,
          columnSpacing: 14,
          columns: const [
            DataColumn(label: Text('SKU', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('الصنف', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('التصنيف', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('وحدة', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('آخر بيع', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('تكلفة', style: TextStyle(fontSize: 12)), numeric: true),
            DataColumn(label: Text('سعر البيع', style: TextStyle(fontSize: 12)), numeric: true),
          ],
          rows: _rows.map((p) {
            return DataRow(
              color: WidgetStatePropertyAll(Colors.red.withValues(alpha: 0.04)),
              cells: [
                DataCell(Text(
                  (p['sku'] as String?) ?? '-',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                )),
                DataCell(ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    (p['name'] as String?) ?? '-',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
                DataCell(Text(
                  _catLabel(p['category_slug'] as String?),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                )),
                DataCell(Text((p['unit_id'] as String?) ?? '-',
                    style: const TextStyle(fontSize: 11))),
                DataCell(Text(_fmtDate(p['last_sale'] as String?),
                    style: const TextStyle(fontSize: 11, color: Colors.grey))),
                DataCell(Text(_fmtNum((p['standard_cost'] as num?) ?? 0),
                    style: const TextStyle(fontSize: 11))),
                DataCell(Text(_fmtNum((p['sale_price'] as num?) ?? 0),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}