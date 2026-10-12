import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../services/permission_service.dart';

/// شاشة إدارة الصلاحيات — تصميم احترافي بـ 7 أقسام
class PermissionsScreen extends StatefulWidget {
  final Database db;
  const PermissionsScreen({super.key, required this.db});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final PermissionService _service;

  static const List<Map<String, Object>> _categories = [
    {'key': 'file',     'name': 'ملف',      'icon': Icons.folder_outlined,       'color': 0xFF2196F3},
    {'key': 'ops',      'name': 'العمليات', 'icon': Icons.receipt_long_outlined, 'color': 0xFF4CAF50},
    {'key': 'reports',  'name': 'التقارير', 'icon': Icons.bar_chart_outlined,    'color': 0xFF9C27B0},
    {'key': 'settings', 'name': 'التهيئة',  'icon': Icons.settings_outlined,     'color': 0xFFFF9800},
    {'key': 'sec',      'name': 'الأمن',    'icon': Icons.shield_outlined,       'color': 0xFFF44336},
    {'key': 'help',     'name': 'مساعدة',   'icon': Icons.help_outline,          'color': 0xFF00BCD4},
    {'key': 'app',      'name': 'التطبيق',  'icon': Icons.apps_outlined,         'color': 0xFF607D8B},
    {'key': 'grants',   'name': 'منح',       'icon': Icons.verified_user_outlined, 'color': 0xFFE91E63},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _service = PermissionService(widget.db);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 20,
          title: Row(
            children: [
              const Icon(Icons.security, size: 22),
              const SizedBox(width: 10),
              const Text(
                'إدارة الصلاحيات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text('المدير العام',
                        style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          bottom: TabBar(
            controller: _tab,
            isScrollable: true,
            indicatorColor: const Color(0xFF64B5F6),
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [
              for (final c in _categories)
                Tab(
                  icon: Icon(c['icon'] as IconData, size: 20),
                  text: c['name'] as String,
                  height: 64,
                ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            for (final c in _categories)
              _CategoryView(
                service: _service,
                categoryKey: c['key'] as String,
                categoryName: c['name'] as String,
                accentColor: Color(c['color'] as int),
                categoryIcon: c['icon'] as IconData,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryView extends StatefulWidget {
  final PermissionService service;
  final String categoryKey;
  final String categoryName;
  final Color accentColor;
  final IconData categoryIcon;

  const _CategoryView({
    required this.service,
    required this.categoryKey,
    required this.categoryName,
    required this.accentColor,
    required this.categoryIcon,
  });

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  List<Map<String, dynamic>>? _all;
  List<Map<String, dynamic>>? _filtered;
  bool _loading = true;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

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
    final perms = await widget.service.byCategory(widget.categoryKey);
    if (mounted) {
      setState(() {
        _all = perms;
        _filtered = perms;
        _loading = false;
      });
    }
  }

  void _applySearch(String q) {
    final query = q.trim().toLowerCase();
    setState(() {
      _searchQuery = q;
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = (_all ?? const [])
            .where((p) =>
                (p['name_ar'] as String? ?? '').toLowerCase().contains(query) ||
                (p['code'] as String? ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final all = _all ?? const <Map<String, dynamic>>[];
    final filtered = _filtered ?? all;

    return Column(
      children: [
        // ─── Toolbar ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.accentColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.categoryIcon,
                    color: widget.accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.categoryName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${filtered.length} / ${all.length} صلاحية',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _applySearch,
                  decoration: InputDecoration(
                    hintText: 'ابحث في الصلاحيات...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _applySearch('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.done_all,
                label: 'تحديد الكل',
                color: Colors.green.shade700,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.remove_done,
                label: 'إلغاء الكل',
                color: Colors.red.shade400,
                onTap: () {},
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.grey.shade200),
        // ─── Content ───
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off,
                          size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        _searchQuery.isEmpty
                            ? 'لا توجد صلاحيات في "${widget.categoryName}"'
                            : 'لا توجد نتائج مطابقة لـ "$_searchQuery"',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = constraints.maxWidth > 1000
                        ? 3
                        : constraints.maxWidth > 650
                            ? 2
                            : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.all(14),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisExtent: 66,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _PermissionCard(
                          data: filtered[index],
                          accentColor: widget.accentColor,
                        );
                      },
                    );
                  },
                ),
        ),
        // ─── Footer ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('حفظ التغييرات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('تراجع'),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.orange.shade800),
                    const SizedBox(width: 6),
                    Text(
                      'وضع العرض فقط',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color accentColor;

  const _PermissionCard({required this.data, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data['name_ar'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  data['code'] as String? ?? '',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: color.withAlpha(80)),
          borderRadius: BorderRadius.circular(8),
          color: color.withAlpha(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}