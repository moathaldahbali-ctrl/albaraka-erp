// tools/seed_hasura.dart — v9.4.5a-FIX2 (يوسّع *ALL* قبل الدمج)
import 'dart:io';
import '../lib/data/seeds/permissions_seed.dart';

void main() {
  final buf = StringBuffer();
  buf.writeln("BEGIN;");

  // قائمة كل الصلاحيات (للتوسيع)
  final allCodes = PermissionsSeed.allExtended
      .map((p) => (p['code'] ?? p['key']) as String)
      .toList();

  // 1) permissions
  int permCount = 0;
  for (final p in PermissionsSeed.allExtended) {
    final id = _esc(p['code'] ?? p['key']);
    final cat = _esc(p['category']);
    final lbl = _esc(p['name_ar']);
    buf.writeln(
      "INSERT INTO permissions (id, category, label_ar, is_active) "
      "VALUES ('$id', '$cat', '$lbl', true) "
      "ON CONFLICT (id) DO UPDATE SET category = EXCLUDED.category, label_ar = EXCLUDED.label_ar;"
    );
    permCount++;
  }

  // 2) roles
  int roleCount = 0;
  for (final r in PermissionsSeed.roles) {
    final id = _esc(r['code'] ?? r['id']);
    final nm = _esc(r['name_ar'] ?? r['display_name_ar'] ?? id);
    final sys = (r['is_system'] == true || r['is_system'] == 1) ? 'true' : 'false';
    buf.writeln(
      "INSERT INTO roles (id, name, display_name_ar, is_system) "
      "VALUES ('$id', '$id', '$nm', $sys) "
      "ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, display_name_ar = EXCLUDED.display_name_ar;"
    );
    roleCount++;
  }

  // 3) role_permissions — نستخدم allRoleAssignments المدمجة (v9.4.5b-LITE)
  //    توسيع *ALL* قبل الاستخدام
  final raw = PermissionsSeed.allRoleAssignments;
  final merged = <String, List<String>>{};

  raw.forEach((k, v) {
    if (v.length == 1 && v.first == '*ALL*') {
      merged[k] = List<String>.from(allCodes);
    } else {
      merged[k] = List<String>.from(v);
    }
  });

  // إزالة التكرار
  merged.forEach((k, v) {
    merged[k] = v.toSet().toList();
  });

  // د) توليد INSERT
  int rpCount = 0;
  for (final entry in merged.entries) {
    for (final code in entry.value) {
      buf.writeln(
        "INSERT INTO role_permissions (role_id, permission_id) "
        "VALUES ('${_esc(entry.key)}', '${_esc(code)}') "
        "ON CONFLICT DO NOTHING;"
      );
      rpCount++;
    }
  }

  buf.writeln("COMMIT;");

  final outPath = r'D:\albaraka\hasura_seed.sql';
  File(outPath).writeAsStringSync(buf.toString());
  print('Written: $outPath (${buf.length} chars)');
  print('   permissions: $permCount');
  print('   roles: $roleCount');
  print('   role_permissions: $rpCount');
}

String _esc(dynamic v) {
  if (v == null) return '';
  return v.toString().replaceAll("'", "''");
}