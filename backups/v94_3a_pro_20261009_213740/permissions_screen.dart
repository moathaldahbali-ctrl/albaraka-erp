import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../services/permission_service.dart';

class PermissionsScreen extends StatelessWidget {
  final Database db;
  const PermissionsScreen({super.key, required this.db});

  static const List<Map<String, Object>> _categories = [
    {'key': 'file',     'name': 'ملف',       'icon': Icons.folder},
    {'key': 'ops',      'name': 'العمليات',  'icon': Icons.receipt_long},
    {'key': 'reports',  'name': 'التقارير',  'icon': Icons.bar_chart},
    {'key': 'settings', 'name': 'التهيئة',   'icon': Icons.settings},
    {'key': 'sec',      'name': 'الأمن',     'icon': Icons.security},
    {'key': 'help',     'name': 'مساعدة',    'icon': Icons.help_outline},
    {'key': 'app',      'name': 'التطبيق',   'icon': Icons.apps},
  ];

  @override
  Widget build(BuildContext context) {
    final service = PermissionService(db);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: _categories.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إدارة الصلاحيات'),
            bottom: TabBar(
              isScrollable: true,
              tabs: [
                for (final c in _categories)
                  Tab(
                    icon: Icon(c['icon'] as IconData, size: 20),
                    text: c['name'] as String,
                  ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              for (final c in _categories)
                _CategoryView(
                  service: service,
                  categoryKey: c['key'] as String,
                  categoryName: c['name'] as String,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryView extends StatefulWidget {
  final PermissionService service;
  final String categoryKey;
  final String categoryName;

  const _CategoryView({
    required this.service,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<_CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<_CategoryView> {
  List<Map<String, dynamic>>? _permissions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final perms = await widget.service.byCategory(widget.categoryKey);
    if (mounted) {
      setState(() {
        _permissions = perms;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final perms = _permissions ?? const <Map<String, dynamic>>[];
    if (perms.isEmpty) {
      return Center(
        child: Text('لا توجد صلاحيات في "${widget.categoryName}"'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: perms.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final p = perms[index];
        return ListTile(
          dense: true,
          leading: const Icon(Icons.check_circle_outline, color: Colors.green),
          title: Text(
            p['name_ar'] as String? ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            p['code'] as String? ?? '',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }
}