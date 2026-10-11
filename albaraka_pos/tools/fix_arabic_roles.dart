// tools/fix_arabic_roles.dart
// v8.3.7e — إصلاح تشويه display_name_ar في جدول roles
import 'dart:convert';
import 'dart:io';
import '../lib/data/seeds/permissions_seed.dart';

void main() {
  final buf = StringBuffer();
  buf.writeln('-- v8.3.7e: Fix Arabic display_name_ar in roles');
  buf.writeln('BEGIN;');

  int count = 0;

  // قائمة الأدوار المعروفة (من permissions_seed)
  for (final r in PermissionsSeed.roles) {
    final id = (r['code'] ?? r['id']) as String?;
    final nameAr = (r['name_ar'] ?? r['display_name_ar'] ?? id) as String?;
    if (id == null || nameAr == null || nameAr.isEmpty) continue;

    final escapedId = id.replaceAll("'", "''");
    final escapedNameAr = nameAr.replaceAll("'", "''");

    buf.writeln(
      "UPDATE roles SET display_name_ar = '$escapedNameAr' "
      "WHERE id = '$escapedId';"
    );
    count++;
  }

  buf.writeln('COMMIT;');

  final outPath = r'D:\albaraka\fix_arabic_roles.sql';
  final file = File(outPath);
  file.writeAsStringSync(buf.toString(), encoding: utf8, flush: true);

  print('OK written: $outPath');
  print('Total UPDATEs: $count');
  print('File size: ${file.lengthSync()} bytes');
  print('');
  print('NEXT: Open this file in NOTEPAD, copy, paste in Hasura.');
}