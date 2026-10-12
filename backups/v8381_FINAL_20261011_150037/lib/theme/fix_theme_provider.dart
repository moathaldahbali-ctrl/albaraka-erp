// tools/fix_theme_provider.dart
// Fix: duplicate import + mangled Arabic comments
// 2026-10-07

import 'dart:io';
import 'dart:convert';

void main() {
  const path = r'D:\albaraka\albaraka_pos\lib\theme\theme_provider.dart';
  final file = File(path);

  if (!file.existsSync()) {
    print('❌ file not found: $path');
    return;
  }

  // 1. Backup
  final bak = File('$path.bak_20261007_fix');
  if (!bak.existsSync()) {
    file.copySync(bak.path);
    print('💾 backup: ${bak.path}');
  }

  // 2. Read UTF-8
  var content = file.readAsStringSync(encoding: utf8);

  // 3. Remove duplicate import (line with sqflite import + trailing // comment)
  final before = content.length;
  content = content.replaceAll(
    RegExp(
      r"import 'package:sqflite_common_ffi/sqflite_ffi\.dart';\s*//[^\r\n]*\r?\n",
    ),
    '',
  );

  // 4. Fix mangled header comments (lines 2-3)
  // Replace any mangled comment line at top with clean English
  final lines = content.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length && i < 5; i++) {
    final l = lines[i];
    if (l.startsWith('// lib/theme/theme_provider.dart')) {
      if (i + 1 < lines.length) {
        lines[i + 1] = '// Theme state management (preset + mode) - saved in drafts_local';
      }
      if (i + 2 < lines.length) {
        lines[i + 2] = '// Last update: 2026-10-07';
      }
      break;
    }
  }
  content = lines.join('\n');

  // 5. Remove BOM if present + ensure UTF-8 no BOM
  if (content.startsWith('\uFEFF')) {
    content = content.substring(1);
  }

  // 6. Write
  file.writeAsStringSync(content, encoding: utf8, flush: true);

  print('✅ fixed');
  print('   size: $before -> ${content.length} chars');
}