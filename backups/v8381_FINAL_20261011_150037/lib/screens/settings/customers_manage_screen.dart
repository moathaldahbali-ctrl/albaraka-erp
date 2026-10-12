import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uuid/uuid.dart';
import '../../db/local_db.dart';
import '../../services/auth_service.dart';

/// v9.3 — بيانات العملاء الكاملة (نمط البركة) + فلترة الصلاحيات
class CustomersManageScreen extends StatefulWidget {
  const CustomersManageScreen({super.key});

  @override
  State<CustomersManageScreen> createState() => _CustomersManageScreenState();
}

class _CustomersManageScreenState extends State<CustomersManageScreen> {
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String _statusFilter = 'all';

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
    final db = await LocalDatabase.instance.database;

    String where = "WHERE code != 'WALKIN'";
    if (_statusFilter == 'active') where += " AND is_active = 1";
    if (_statusFilter == 'inactive') where += " AND is_active = 0";

    if (_search.trim().isNotEmpty) {
      final s = _search.trim().replaceAll("'", "''");
      where += " AND (name LIKE '%$s%' OR phone LIKE '%$s%' OR phone2 LIKE '%$s%' OR code LIKE '%$s%' OR name_foreign LIKE '%$s%')";
    }

    final rows = await db.rawQuery('''
      SELECT * FROM customers_local
      $where
      ORDER BY name ASC
      LIMIT 500
    ''');

    if (mounted) {
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);
  bool _can(String slug) => AuthService.instance.has(slug);

  Future<void> _showAddDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _CustomerDialog(),
    );
    if (result != null) {
      await _saveCustomer(result, isNew: true);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> c) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CustomerDialog(customer: c),
    );
    if (result != null) {
      await _saveCustomer(result, isNew: false);
    }
  }

  Future<void> _saveCustomer(Map<String, dynamic> data, {required bool isNew}) async {
    final db = await LocalDatabase.instance.database;
    try {
      if (isNew) {
        final maxCode = await db.rawQuery(
            "SELECT MAX(CAST(code AS INTEGER)) AS c FROM customers_local WHERE code != 'WALKIN'");
        final nextCode = ((maxCode.first['c'] as num?)?.toInt() ?? 0) + 1;
        final id = const Uuid().v4();

        await db.rawInsert('''
          INSERT INTO customers_local
            (id, code, name, name_foreign, id_code, index_number,
             phone, phone2, fax, email, address, po_box,
             activity_type, due_days, credit_limit, discount_percent,
             commission_percent, group_name, account_number, currency_code,
             payment_method, force_special_price, force_installment,
             notes, is_active, synced_at)
          VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1,'')
        ''', [
          id, nextCode.toString(),
          data['name'], data['name_foreign'],
          data['id_code'], data['index_number'],
          data['phone'], data['phone2'], data['fax'], data['email'],
          data['address'], data['po_box'],
          data['activity_type'], data['due_days'],
          data['credit_limit'], data['discount_percent'],
          data['commission_percent'], data['group_name'],
          data['account_number'], data['currency_code'],
          data['payment_method'], data['force_special_price'],
          data['force_installment'], data['notes'],
        ]);
      } else {
        await db.rawUpdate('''
          UPDATE customers_local SET
            name = ?, name_foreign = ?, id_code = ?, index_number = ?,
            phone = ?, phone2 = ?, fax = ?, email = ?,
            address = ?, po_box = ?, activity_type = ?, due_days = ?,
            credit_limit = ?, discount_percent = ?, commission_percent = ?,
            group_name = ?, account_number = ?, currency_code = ?,
            payment_method = ?, force_special_price = ?, force_installment = ?,
            notes = ?, synced_at = ''
          WHERE id = ?
        ''', [
          data['name'], data['name_foreign'],
          data['id_code'], data['index_number'],
          data['phone'], data['phone2'], data['fax'], data['email'],
          data['address'], data['po_box'],
          data['activity_type'], data['due_days'],
          data['credit_limit'], data['discount_percent'],
          data['commission_percent'], data['group_name'],
          data['account_number'], data['currency_code'],
          data['payment_method'], data['force_special_price'],
          data['force_installment'], data['notes'],
          data['id'],
        ]);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNew ? 'تم إضافة العميل ✓' : 'تم تحديث العميل ✓'),
          backgroundColor: Colors.green,
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> c) async {
    final active = (c['is_active'] as num?)?.toInt() == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(active ? 'إيقاف التعامل؟' : 'تنشيط العميل؟'),
        content: Text('"${c['name']}" — ${active ? 'سيُوقف' : 'سيُنشَّط'}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: active ? Colors.red : Colors.green),
            child: Text(active ? 'إيقاف' : 'تنشيط'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final db = await LocalDatabase.instance.database;
    await db.rawUpdate('UPDATE customers_local SET is_active = ? WHERE id = ?',
        [active ? 0 : 1, c['id']]);
    if (!mounted) return;
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بيانات العملاء'),
          actions: [
            if (_can('customers.create'))
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'إضافة عميل جديد',
                onPressed: _showAddDialog,
              ),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'تحديث'),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(theme),
            _buildSummary(theme),
            const Divider(height: 1),
            Expanded(child: _buildTable(theme)),
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
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('الكل')),
              ButtonSegment(value: 'active', label: Text('نشط')),
              ButtonSegment(value: 'inactive', label: Text('موقوف')),
            ],
            selected: {_statusFilter},
            onSelectionChanged: (s) {
              setState(() => _statusFilter = s.first);
              _load();
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'بحث بالاسم/الهاتف/الرقم',
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

  Widget _buildSummary(ThemeData theme) {
    final active = _rows.where((r) => (r['is_active'] as num?)?.toInt() == 1).length;
    final inactive = _rows.length - active;
    final withLimit = _rows.where((r) => ((r['credit_limit'] as num?)?.toDouble() ?? 0) > 0).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _statCard(theme, 'الإجمالي', '${_rows.length}', Colors.blue),
          const SizedBox(width: 6),
          _statCard(theme, 'نشط', '$active', Colors.green),
          const SizedBox(width: 6),
          _statCard(theme, 'موقوف', '$inactive', Colors.grey),
          const SizedBox(width: 6),
          _statCard(theme, 'بحد ائتماني', '$withLimit', Colors.orange),
        ],
      ),
    );
  }

  Widget _statCard(ThemeData theme, String title, String count, Color color) {
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
            Text(count, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_rows.isEmpty) {
      return const Center(child: Text('لا يوجد عملاء بهذا الفلتر'));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowHeight: 36,
          dataRowMinHeight: 32,
          dataRowMaxHeight: 40,
          horizontalMargin: 12,
          columnSpacing: 12,
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('الاسم', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('الهاتف', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('النشاط', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('المجموعة', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('الحد', style: TextStyle(fontSize: 12)), numeric: true),
            DataColumn(label: Text('الحالة', style: TextStyle(fontSize: 12))),
            DataColumn(label: Text('إجراءات', style: TextStyle(fontSize: 12))),
          ],
          rows: _rows.map((c) {
            final active = (c['is_active'] as num?)?.toInt() == 1;
            final limit = (c['credit_limit'] as num?)?.toDouble() ?? 0;
            return DataRow(cells: [
              DataCell(Text((c['code'] as String?) ?? '-',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey))),
              DataCell(ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Text((c['name'] as String?) ?? '-',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              )),
              DataCell(Text((c['phone'] as String?) ?? '-',
                  style: const TextStyle(fontSize: 11))),
              DataCell(Text(_activityLabel(c['activity_type'] as String?),
                  style: const TextStyle(fontSize: 11))),
              DataCell(Text((c['group_name'] as String?) ?? '-',
                  style: const TextStyle(fontSize: 11, color: Colors.grey))),
              DataCell(Text(limit == 0 ? 'غير محدود' : _fmtNum(limit),
                  style: const TextStyle(fontSize: 11))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (active ? Colors.green : Colors.grey).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(active ? 'نشط' : 'موقوف',
                    style: TextStyle(
                        fontSize: 10,
                        color: active ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold)),
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_can('customers.edit'))
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18, color: Colors.blue),
                      tooltip: 'تعديل',
                      onPressed: () => _showEditDialog(c),
                    ),
                  if (_can('customers.deactivate'))
                    IconButton(
                      icon: Icon(active ? Icons.block : Icons.check_circle_outline,
                          size: 18, color: active ? Colors.red : Colors.green),
                      tooltip: active ? 'إيقاف' : 'تنشيط',
                      onPressed: () => _toggleActive(c),
                    ),
                  if (!_can('customers.edit') && !_can('customers.deactivate'))
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('—', style: TextStyle(color: Colors.grey)),
                    ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _activityLabel(String? t) {
    switch (t) {
      case 'retail': return 'تجزئة';
      case 'wholesale': return 'جملة';
      case 'restaurant': return 'مطعم';
      case 'company': return 'شركة';
      default: return t ?? 'تجزئة';
    }
  }
}

class _CustomerDialog extends StatefulWidget {
  final Map<String, dynamic>? customer;
  const _CustomerDialog({this.customer});

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  int _currentTab = 0;

  late TextEditingController _nameCtrl, _nameForeignCtrl, _idCodeCtrl,
      _phoneCtrl, _phone2Ctrl, _faxCtrl, _emailCtrl,
      _addressCtrl, _poBoxCtrl, _notesCtrl,
      _limitCtrl, _discountCtrl, _commissionCtrl,
      _groupCtrl, _accountCtrl;

  String _activityType = 'retail';
  String _currency = 'YER';
  String _paymentMethod = 'cash';
  int _dueDays = 0;
  int _indexNumber = 0;
  bool _forceSpecialPrice = false;
  bool _forceInstallment = false;

  bool get isEdit => widget.customer != null;

  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _nameCtrl = TextEditingController(text: (c?['name'] as String?) ?? '');
    _nameForeignCtrl = TextEditingController(text: (c?['name_foreign'] as String?) ?? '');
    _idCodeCtrl = TextEditingController(text: (c?['id_code'] as String?) ?? '');
    _phoneCtrl = TextEditingController(text: (c?['phone'] as String?) ?? '');
    _phone2Ctrl = TextEditingController(text: (c?['phone2'] as String?) ?? '');
    _faxCtrl = TextEditingController(text: (c?['fax'] as String?) ?? '');
    _emailCtrl = TextEditingController(text: (c?['email'] as String?) ?? '');
    _addressCtrl = TextEditingController(text: (c?['address'] as String?) ?? '');
    _poBoxCtrl = TextEditingController(text: (c?['po_box'] as String?) ?? '');
    _notesCtrl = TextEditingController(text: (c?['notes'] as String?) ?? '');
    _limitCtrl = TextEditingController(text: ((c?['credit_limit'] as num?)?.toString()) ?? '0');
    _discountCtrl = TextEditingController(text: ((c?['discount_percent'] as num?)?.toString()) ?? '0');
    _commissionCtrl = TextEditingController(text: ((c?['commission_percent'] as num?)?.toString()) ?? '0');
    _groupCtrl = TextEditingController(text: (c?['group_name'] as String?) ?? '');
    _accountCtrl = TextEditingController(text: (c?['account_number'] as String?) ?? '');

    _activityType = (c?['activity_type'] as String?) ?? 'retail';
    _currency = (c?['currency_code'] as String?) ?? 'YER';
    _paymentMethod = (c?['payment_method'] as String?) ?? 'cash';
    _dueDays = ((c?['due_days'] as num?)?.toInt()) ?? 0;
    _indexNumber = ((c?['index_number'] as num?)?.toInt()) ?? 0;
    _forceSpecialPrice = ((c?['force_special_price'] as num?)?.toInt() ?? 0) == 1;
    _forceInstallment = ((c?['force_installment'] as num?)?.toInt() ?? 0) == 1;
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _nameForeignCtrl, _idCodeCtrl, _phoneCtrl,
        _phone2Ctrl, _faxCtrl, _emailCtrl, _addressCtrl, _poBoxCtrl, _notesCtrl,
        _limitCtrl, _discountCtrl, _commissionCtrl, _groupCtrl, _accountCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        child: SizedBox(
          width: 680,
          height: 620,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                child: Row(
                  children: [
                    Icon(isEdit ? Icons.edit : Icons.person_add,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isEdit ? 'تعديل العميل: ${widget.customer!['name']}' : 'إضافة عميل جديد',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTabButton(0, Icons.person, 'شخصية'),
                    _buildTabButton(1, Icons.info_outline, 'تفاصيل'),
                    _buildTabButton(2, Icons.account_balance_wallet, 'حسابات'),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: _currentTab == 0
                      ? _buildPersonalTab()
                      : _currentTab == 1
                          ? _buildDetailsTab()
                          : _buildAccountsTab(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: _submit,
                      label: Text(isEdit ? 'حفظ' : 'إضافة'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final selected = _currentTab == index;
    final color = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.08) : null,
            border: Border(
              bottom: BorderSide(
                color: selected ? color : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: selected ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: selected ? color : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            _f('الاسم', _nameCtrl, required: true, flex: 2),
            const SizedBox(width: 12),
            _f('الاسم الأجنبي', _nameForeignCtrl),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _f('رمز التعريف', _idCodeCtrl),
            const SizedBox(width: 12),
            _numF('رقم الفهرس', initial: _indexNumber, onChanged: (v) => _indexNumber = v),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _f('الهاتف', _phoneCtrl, keyboard: TextInputType.phone),
            const SizedBox(width: 12),
            _f('هاتف بديل', _phone2Ctrl, keyboard: TextInputType.phone),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _f('الفاكس', _faxCtrl),
            const SizedBox(width: 12),
            _f('البريد الإلكتروني', _emailCtrl, keyboard: TextInputType.emailAddress),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _fBlock('العنوان', _addressCtrl),
          const SizedBox(height: 12),
          Row(children: [
            _f('ص.ب', _poBoxCtrl),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _activityType,
                decoration: const InputDecoration(
                  labelText: 'نوع النشاط',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'retail', child: Text('تجزئة')),
                  DropdownMenuItem(value: 'wholesale', child: Text('جملة')),
                  DropdownMenuItem(value: 'restaurant', child: Text('مطعم')),
                  DropdownMenuItem(value: 'company', child: Text('شركة')),
                ],
                onChanged: (v) => setState(() => _activityType = v ?? 'retail'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                initialValue: _dueDays.toString(),
                decoration: const InputDecoration(
                  labelText: 'فترة الاستحقاق (يوم)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => _dueDays = int.tryParse(v) ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: 'العملة',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'YER', child: Text('YER')),
                  DropdownMenuItem(value: 'SAR', child: Text('SAR')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                ],
                onChanged: (v) => setState(() => _currency = v ?? 'YER'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          _fBlock('ملاحظات', _notesCtrl, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildAccountsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(children: [
            _f('الحد الائتماني (0 = غير محدود)', _limitCtrl, keyboard: TextInputType.number),
            const SizedBox(width: 12),
            _f('نسبة الخصم %', _discountCtrl, keyboard: TextInputType.number),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _f('نسبة العمولة %', _commissionCtrl, keyboard: TextInputType.number),
            const SizedBox(width: 12),
            _f('المجموعة', _groupCtrl),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _f('رقم الحساب', _accountCtrl),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(
                  labelText: 'طريقة الدفع',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('نقد')),
                  DropdownMenuItem(value: 'credit', child: Text('آجل')),
                  DropdownMenuItem(value: 'mixed', child: Text('مختلط')),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v ?? 'cash'),
              ),
            ),
          ]),
          const Divider(height: 32),
          const Text('خيارات متقدمة',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          CheckboxListTile(
            dense: true,
            title: const Text('البيع بسعر خاص إجباري', style: TextStyle(fontSize: 12)),
            value: _forceSpecialPrice,
            onChanged: (v) => setState(() => _forceSpecialPrice = v ?? false),
          ),
          CheckboxListTile(
            dense: true,
            title: const Text('إجبار تحصيل الأقساط', style: TextStyle(fontSize: 12)),
            value: _forceInstallment,
            onChanged: (v) => setState(() => _forceInstallment = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _f(String label, TextEditingController c,
      {bool required = false, int flex = 1, int maxLines = 1, TextInputType? keyboard}) {
    return Expanded(
      flex: flex,
      child: TextFormField(
        controller: c,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null
            : null,
      ),
    );
  }

  Widget _fBlock(String label, TextEditingController c,
      {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: c,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      maxLines: maxLines,
      keyboardType: keyboard,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null
          : null,
    );
  }

  Widget _numF(String label, {required int initial, required ValueChanged<int> onChanged}) {
    return Expanded(
      child: TextFormField(
        initialValue: initial.toString(),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
        keyboardType: TextInputType.number,
        onChanged: (v) => onChanged(int.tryParse(v) ?? 0),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(context, {
      if (isEdit) 'id': widget.customer!['id'],
      'name': _nameCtrl.text.trim(),
      'name_foreign': _nameForeignCtrl.text.trim(),
      'id_code': _idCodeCtrl.text.trim(),
      'index_number': _indexNumber,
      'phone': _phoneCtrl.text.trim(),
      'phone2': _phone2Ctrl.text.trim(),
      'fax': _faxCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'po_box': _poBoxCtrl.text.trim(),
      'activity_type': _activityType,
      'due_days': _dueDays,
      'credit_limit': double.tryParse(_limitCtrl.text.trim()) ?? 0,
      'discount_percent': double.tryParse(_discountCtrl.text.trim()) ?? 0,
      'commission_percent': double.tryParse(_commissionCtrl.text.trim()) ?? 0,
      'group_name': _groupCtrl.text.trim(),
      'account_number': _accountCtrl.text.trim(),
      'currency_code': _currency,
      'payment_method': _paymentMethod,
      'force_special_price': _forceSpecialPrice ? 1 : 0,
      'force_installment': _forceInstallment ? 1 : 0,
      'notes': _notesCtrl.text.trim(),
    });
  }
}