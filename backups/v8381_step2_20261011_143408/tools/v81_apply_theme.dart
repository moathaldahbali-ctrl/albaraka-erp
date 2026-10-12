// tools/v81_apply_theme.dart
// v8.1/3 — ربط AppTheme في main.dart
// 2026-10-07

import 'dart:io';
import 'dart:convert';

class Edit {
  final String find;
  final String replace;
  const Edit(this.find, this.replace);
}

void main() {
  const root = r'D:\albaraka\albaraka_pos';
  const stamp = '20261007_v81_theme';

  final edits = <String, List<Edit>>{
    r'lib\main.dart': [
      // 1. import
      Edit(
        "import 'sync/sync_manager.dart';",
        "import 'sync/sync_manager.dart';\nimport 'theme/app_theme.dart';",
      ),
      // 2. theme
      Edit(
        "      debugShowCheckedModeBanner: false,\n      locale:",
        "      debugShowCheckedModeBanner: false,\n      theme: AppTheme.light,\n      locale:",
      ),
    ],
  };

  var totalOk = 0;
  var totalFail = 0;

  edits.forEach((rel, list) {
    final path = '$root\\$rel';
    final file = File(path);
    if (!file.existsSync()) {
      print('❌ $rel : NOT FOUND');
      totalFail += list.length;
      return;
    }

    // نسخة احتياطية
    final bak = File('$path.bak_$stamp');
    if (!bak.existsSync()) {
      file.copySync(bak.path);
      print('💾 backup: ${bak.path}');
    } else {
      print('ℹ️  backup exists: ${bak.path}');
    }

    var content = file.readAsStringSync(encoding: utf8);
    var ok = 0;
    var fail = 0;

    for (final e in list) {
      if (content.contains(e.find)) {
        content = content.replaceFirst(e.find, e.replace);
        ok++;
      } else {
        final preview = e.find.split("\n").first.trim();
        print('  ⚠️  NOT FOUND in $rel : "$preview"');
        fail++;
      }
    }

    file.writeAsStringSync(content, encoding: utf8, flush: true);
    print('✅ $rel : $ok applied, $fail failed');
    totalOk += ok;
    totalFail += fail;
  });

  print('');
  print('═══════════════════════════════════');
  print('  Total: $totalOk applied, $totalFail failed');
  print('═══════════════════════════════════');
}