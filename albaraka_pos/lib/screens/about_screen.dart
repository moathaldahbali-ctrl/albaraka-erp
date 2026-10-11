import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../db/local_db.dart';

/// v8.3.8 — شاشة "عن النظام"
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  bool _loading = true;

  // Stats
  int _products = 0, _customers = 0, _users = 0, _sales = 0, _sessions = 0;
  String? _cashierName;
  Map<String, dynamic>? _session;
  String? _dbPath;
  String? _dbSize;

  static const String kAppName = 'بقالة وبهارات البركة';
  static const String kAppSubtitle = 'نظام نقاط البيع وإدارة المخزون';
  static const String kVersion = 'v8.3';
  static const String kBuildDate = '2026-10-08';
  static const String kBranchName = 'الفرع الرئيسي';
  static const String kBranchAddress = 'صنعاء — ش بيحان المتفرع من ش 22 مايو';
  static const String kBranchPhone = '772025928';
  static const String kServerEndpoint =
      'eewgyrglhvkxjwzevcwm.hasura.ap-southeast-1.nhost.run';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = await LocalDatabase.instance.database;

    _products = await _count(db, 'products_local');
    _customers = await _count(db, 'customers_local');
    _users = await _count(db, 'users_local');
    _sales = await _count(db, 'sales_local');
    _sessions = await _count(db, 'register_sessions_local');

    _cashierName = await LocalDatabase.instance.getCurrentUserName();
    _session = await LocalDatabase.instance.getActiveSession();

    _dbPath = db.path;
    try {
      final f = File(db.path);
      if (await f.exists()) {
        final bytes = await f.length();
        _dbSize = '${(bytes / 1024).toStringAsFixed(0)} KB';
      }
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  Future<int> _count(dynamic db, String table) async {
    try {
      final r = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
      if (r.isNotEmpty) return (r.first['c'] as num?)?.toInt() ?? 0;
    } catch (_) {}
    return 0;
  }

  String _fmtNum(num n) => NumberFormat('#,##0.##').format(n);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عن النظام')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo + Title
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo_color.png',
                            width: 100,
                            height: 100,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.store,
                              size: 80,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            kAppName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kAppSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Chip(
                            label: Text(kVersion,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            backgroundColor:
                                theme.colorScheme.primary.withValues(alpha: 0.15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'بناء: $kBuildDate',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _section(theme, '🏢 معلومات الفرع', [
                      _row('الاسم', kBranchName),
                      _row('العنوان', kBranchAddress),
                      _row('الهاتف', kBranchPhone),
                    ]),

                    _section(theme, '👤 جلسة المستخدم', [
                      _row('الكاشير', _cashierName ?? '-'),
                      _row('الوردية',
                          _session == null ? 'لا توجد' : 'مفتوحة'),
                      _row('نقد فتح',
                          _session == null ? '-' : _fmtNum((_session!['opening_cash'] as num?) ?? 0) + ' YER'),
                    ]),

                    _section(theme, '💾 قاعدة البيانات المحلية', [
                      _row('المسار', _dbPath ?? '-', small: true),
                      _row('الحجم', _dbSize ?? '-'),
                      _row('المنتجات', _fmtNum(_products)),
                      _row('العملاء', _fmtNum(_customers)),
                      _row('المستخدمون', _fmtNum(_users)),
                      _row('الفواتير', _fmtNum(_sales)),
                      _row('الورديات', _fmtNum(_sessions)),
                    ]),

                    _section(theme, '☁️ المزامنة السحابية', [
                      _row('المزوّد', 'Nhost + Hasura'),
                      _row('Endpoint', kServerEndpoint, small: true),
                      _row('الحالة', 'متصل ✓', color: Colors.green),
                    ]),

                    _section(theme, '📱 المنصة التقنية', [
                      _row('نظام التشغيل', 'Windows 10/11 · 64-bit'),
                      _row('Flutter', '3.47.4'),
                      _row('Dart', '3.13.3'),
                      _row('قاعدة البيانات', 'SQLite (sqflite_common_ffi)'),
                      _row('Backend', 'Hasura GraphQL'),
                    ]),

                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        '© 2026 بقالة وبهارات البركة\nصُنع بـ ❤️ في صنعاء، اليمن',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _section(ThemeData theme, String title, List<Widget> rows) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool small = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              k,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: TextStyle(
                fontSize: small ? 11 : 13,
                fontWeight: FontWeight.w600,
                fontFamily: small ? 'monospace' : null,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}