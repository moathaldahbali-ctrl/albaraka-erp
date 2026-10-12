// tools/fix_analyze_issues.dart
// إصلاح 9 مشاكل flutter analyze — 2026-10-07
// التشغيل: dart run tools/fix_analyze_issues.dart

import 'dart:io';
import 'dart:convert';

class Edit {
  final String find;
  final String replace;
  const Edit(this.find, this.replace);
}

void main() {
  const root = r'D:\albaraka\albaraka_pos';
  const stamp = '20261007_analyze_fix';

  final edits = <String, List<Edit>>{
    r'lib\main.dart': [
      Edit(
        "    final openingCash = await showDialog<double>(\n      context: navCtx,",
        "    if (!navCtx.mounted) return;\n    final openingCash = await showDialog<double>(\n      context: navCtx,",
      ),
    ],
    r'lib\screens\sale_screen.dart': [
      // W2 + W3
      Edit(
        "await _saveDraftNow();\n                  if (!mounted) return;",
        "await _saveDraftNow();\n                  if (!mounted || !context.mounted) return;",
      ),
      // W4
      Edit(
        "if (confirmed == true && mounted) {",
        "if (confirmed == true && mounted && context.mounted) {",
      ),
      // I3
      Edit(
        "value: _selectedCategory,",
        "initialValue: _selectedCategory,",
      ),
      // I4
      Edit(
        "value: item.productUnitId,",
        "initialValue: item.productUnitId,",
      ),
    ],
    r'lib\db\local_db.dart': [
      // I1
      Edit(
        "      if (notes != null) 'notes': notes,",
        "      'notes': ?notes,",
      ),
      // I2
      Edit(
        "        if (notes != null) 'notes': notes,",
        "        'notes': ?notes,",
      ),
    ],
    r'lib\widgets\product_picker_dialog.dart': [
      // I5
      Edit(
        "separatorBuilder: (_, __) =>",
        "separatorBuilder: (_, _) =>",
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

    // نسخة احتياطية (مرة واحدة لكل ملف)
    final bak = File('$path.bak_$stamp');
    if (!bak.existsSync()) {
      file.copySync(bak.path);
      print('💾 backup: ${bak.path}');
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