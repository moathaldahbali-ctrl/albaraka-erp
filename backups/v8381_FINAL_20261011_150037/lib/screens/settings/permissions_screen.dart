import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../services/permission_service.dart';

/// شاشة إدارة الصلاحيات — تفاعلية + حفظ
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

  List<Map<String, dynamic>> _roles = [];
  String? _currentRoleId;
  Set<String> _originalPermissions = {};
  Set<String> _currentPermissions = {};
  bool _loading = true;
  bool _saving = false;

  static const List<Map<String, Object>> _categories = [
    {'key': 'file',     'name': 'ملف',       'icon': Icons.folder_outlined,        'color': 0xFF2196F3},
    {'key': 'ops',      'name': 'العمليات',  'icon': Icons.receipt_long_outlined,  'color': 0xFF4CAF50},
    {'key': 'reports',  'name': 'التقارير',  'icon': Icons.bar_chart_outlined,     'color': 0xFF9C27B0},
    {'key': 'settings', 'name': 'التهيئة',   'icon': Icons.settings_outlined,      'color': 0xFFFF9800},
    {'key': 'sec',      'name': 'الأمن',     'icon': Icons.shield_outlined,        'color': 0xFFF44336},
    {'key': 'help',     'name': 'مساعدة',    'icon': Icons.help_outline,           'color': 0xFF00BCD4},
    {'key': 'app',      'name': 'التطبيق',   'icon': Icons.apps_outlined,          'color': 0xFF607D8B},
    {'key': 'grants',   'name': 'منح',       'icon': Icons.verified_user_outlined, 'color': 0xFFE91E63},
  ];

  bool get _isDirty {
    if (_originalPermissions.length != _currentPermissions.length) return true;
    return !_originalPermissions.containsAll(_currentPermissions);
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _categories.length, vsync: this);
    _service = PermissionService(widget.db);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final roles = await _service.getRoles();
    if (roles.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final firstId = roles.first['id'] as String;
    final perms = await _service.getRolePermissions(firstId);
    if (!mounted) return;
    setState(() {
      _roles = roles;
      _currentRoleId = firstId;
      _originalPermissions = Set.of(perms);
      _currentPermissions = Set.of(perms);
      _loading = false;
    });
  }

  Future<void> _changeRole(String roleId) async {
    if (roleId == _currentRoleId) return;
    if (_isDirty) {
      final ok = await _confirmDiscard();
      if (!ok) return;
    }
    setState(() => _loading = true);
    final perms = await _service.getRolePermissions(roleId);
    if (!mounted) return;
    setState(() {
      _currentRoleId = roleId;
      _originalPermissions = Set.of(perms);
      _currentPermissions = Set.of(perms);
      _loading = false;
    });
  }

  Future<bool> _confirmDiscard() async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تغييرات غير محفوظة'),
          content: const Text('لديك تغييرات غير محفوظة. هل تريد تجاهلها؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('تجاهل', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    return r ?? false;
  }

  void _toggle(String code) {
    setState(() {
      if (_currentPermissions.contains(code)) {
        _currentPermissions.remove(code);
      } else {
        _currentPermissions.add(code);
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> perms) {
    setState(() {
      for (final p in perms) {
        _currentPermissions.add(p['code'] as String);
      }
    });
  }

  void _unselectAll(List<Map<String, dynamic>> perms) {
    setState(() {
      for (final p in perms) {
        _currentPermissions.remove(p['code'] as String);
      }
    });
  }

  Future<void> _save() async {
    if (_currentRoleId == null || !_isDirty) return;
    setState(() => _saving = true);
    try {
      await _service.setRolePermissions(_currentRoleId!, _currentPermissions);
      if (!mounted) return;
      setState(() {
        _originalPermissions = Set.of(_currentPermissions);
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حفظ الصلاحيات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل الحفظ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _revert() {
    setState(() {
      _currentPermissions = Set.of(_originalPermissions);
    });
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
              const Text('إدارة الصلاحيات',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildRoleSelector(),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        for (final c in _categories)
                          _CategoryView(
                            key: ValueKey('${c['key']}-$_currentRoleId'),
                            service: _service,
                            categoryKey: c['key'] as String,
                            categoryName: c['name'] as String,
                            accentColor: Color(c['color'] as int),
                            categoryIcon: c['icon'] as IconData,
                            isAllowed: (code) => _currentPermissions.contains(code),
                            onToggle: _toggle,
                            onSelectAll: _selectAll,
                            onUnselectAll: _unselectAll,
                          ),
                      ],
                    ),
                  ),
                  _buildFooter(),
                ],
              ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, color: Color(0xFF1E3A5F), size: 20),
          const SizedBox(width: 10),
          const Text('الدور الحالي:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _currentRoleId,
              underline: const SizedBox.shrink(),
              isDense: true,
              items: _roles
                  .map((r) => DropdownMenuItem<String>(
                        value: r['id'] as String,
                        child: Text(r['name_ar'] as String? ?? ''),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) _changeRole(v);
              },
            ),
          ),
          const SizedBox(width: 20),
          if (_isDirty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 12, color: Colors.orange.shade800),
                  const SizedBox(width: 4),
                  Text('تغييرات غير محفوظة',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final total = _currentPermissions.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: (_isDirty && !_saving) ? _save : null,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save, size: 18),
            label: Text(_saving ? 'جاري الحفظ...' : 'حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A5F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: (_isDirty && !_saving) ? _revert : null,
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('تراجع'),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withAlpha(15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle,
                    size: 14, color: Color(0xFF1E3A5F)),
                const SizedBox(width: 6),
                Text(
                  'المحدد: $total صلاحية',
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E3A5F),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
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
  final bool Function(String code) isAllowed;
  final void Function(String code) onToggle;
  final void Function(List<Map<String, dynamic>> perms) onSelectAll;
  final void Function(List<Map<String, dynamic>> perms) onUnselectAll;

  const _CategoryView({
    super.key,
    required this.service,
    required this.categoryKey,
    required this.categoryName,
    required this.accentColor,
    required this.categoryIcon,
    required this.isAllowed,
    required this.onToggle,
    required this.onSelectAll,
    required this.onUnselectAll,
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
    final selectedCount =
        all.where((p) => widget.isAllowed(p['code'] as String)).length;

    return Column(
      children: [
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
                  Text('$selectedCount / ${all.length} محدد',
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
                onTap: () => widget.onSelectAll(filtered),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.remove_done,
                label: 'إلغاء الكل',
                color: Colors.red.shade400,
                onTap: () => widget.onUnselectAll(filtered),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.grey.shade200),
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
                            : 'لا توجد نتائج لـ "$_searchQuery"',
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
                        final p = filtered[index];
                        final code = p['code'] as String;
                        final allowed = widget.isAllowed(code);
                        return _PermissionCard(
                          data: p,
                          accentColor: widget.accentColor,
                          allowed: allowed,
                          onTap: () => widget.onToggle(code),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color accentColor;
  final bool allowed;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.data,
    required this.accentColor,
    required this.allowed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = allowed ? Colors.green : Colors.grey.shade300;
    final iconWidget = allowed
        ? const Icon(Icons.check_box, color: Colors.green, size: 22)
        : Icon(Icons.check_box_outline_blank,
            color: Colors.grey.shade400, size: 22);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: allowed ? accentColor.withAlpha(80) : Colors.grey.shade200,
            ),
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
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              iconWidget,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      data['name_ar'] as String? ?? '',
                      style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: allowed ? Colors.black87 : Colors.grey.shade600),
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
        ),
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