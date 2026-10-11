// tools/fix_arabic.dart
// v8.3.7e — إصلاح تشويه label_ar في Hasura
// يُولّد SQL مع UPDATE statements بقيم عربية صحيحة
import 'dart:convert';
import 'dart:io';
import '../lib/data/seeds/permissions_seed.dart';

void main() {
  final buf = StringBuffer();
  buf.writeln('-- v8.3.7e: Fix Arabic label_ar in permissions');
  buf.writeln('BEGIN;');

  int count = 0;
  int skipped = 0;

  for (final p in PermissionsSeed.allExtended) {
    final code = (p['code'] ?? p['key']) as String?;
    final label = (p['name_ar'] ?? '') as String;
    if (code == null || code.isEmpty || label.isEmpty) {
      skipped++;
      continue;
    }
    final escapedCode = code.replaceAll("'", "''");
    final escapedLabel = label.replaceAll("'", "''");
    buf.writeln(
      "UPDATE permissions SET label_ar = '$escapedLabel' "
      "WHERE id = '$escapedCode';"
    );
    count++;
  }

  buf.writeln('COMMIT;');

  final outPath = r'D:\albaraka\fix_arabic.sql';
  final file = File(outPath);
  file.writeAsStringSync(buf.toString(), encoding: utf8, flush: true);

  print('OK written: $outPath');
  print('Total UPDATEs: $count');
  print('Skipped: $skipped');
  print('File size: ${file.lengthSync()} bytes');
  print('');
  print('NEXT: Open this file in NOTEPAD (not PowerShell),');
  print('      Copy all, Paste in Hasura SQL Editor, Run.');
}