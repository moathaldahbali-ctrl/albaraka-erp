// lib/screens/settings/categories_tree_screen.dart
// v8.3.8.1 - Hierarchical categories tree (buildTreeTab)
import 'package:flutter/material.dart';
import '../../db/local_db.dart';

class CategoriesTreeScreen extends StatefulWidget {
  const CategoriesTreeScreen({super.key});

  @override
  State<CategoriesTreeScreen> createState() => _CategoriesTreeScreenState();
}

class _CategoriesTreeScreenState extends State<CategoriesTreeScreen> {
  List<Map<String, dynamic>> _tree = <Map<String, dynamic>>[];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await LocalDatabase.instance.getCategoriesTree();
      if (!mounted) return;
      setState(() {
        _tree = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شجرة التصنيفات'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
              onPressed: _load,
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('حدث خطأ في تحميل الشجرة'),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }
    if (_tree.isEmpty) {
      return const Center(child: Text('لا توجد تصنيفات'));
    }
    return buildTreeTab();
  }

  // ═══════════════════════════════════════════════════════════
  // buildTreeTab - الشجرة الهرمية التفاعلية
  // ═══════════════════════════════════════════════════════════
  Widget buildTreeTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _tree.length,
      itemBuilder: (BuildContext context, int index) {
        final node = _tree[index];
        final String name = (node['name'] as String?) ?? '';
        final List<dynamic> children =
            (node['children'] as List<dynamic>?) ?? <dynamic>[];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          elevation: 1,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.category_outlined,
                color:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              '${children.length} تصنيف فرعي',
              style: const TextStyle(fontSize: 12),
            ),
            children: children.map<Widget>((dynamic child) {
              final Map<String, dynamic> c =
                  child as Map<String, dynamic>;
              final String cname = (c['name'] as String?) ?? '';
              final String cslug = (c['slug'] as String?) ?? '';
              return ListTile(
                dense: true,
                leading: const Icon(Icons.label_outline, size: 18),
                title: Text(
                  cname,
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: Text(
                  cslug,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}