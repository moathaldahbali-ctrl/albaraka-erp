import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_enter_$ts').writeAsStringSync(content);

  if (content.contains('onSubmitted: (_) => _confirmClose()')) {
    print('Already patched, skipping.');
    return;
  }

  // === 1. Add onSubmitted + textInputAction to _cashCtrl TextField ===
  final cashRe = RegExp(
      r"(controller: _cashCtrl,\s*\n\s*focusNode: _cashFocus,)");
  if (!cashRe.hasMatch(content)) {
    print('ERROR: _cashCtrl/focusNode block not found.');
    return;
  }
  content = content.replaceFirstMapped(cashRe, (m) {
    return '${m[1]}\n'
        '            textInputAction: TextInputAction.done,\n'
        '            onSubmitted: (_) => _confirmClose(),';
  });

  // === 2. Update label to hint Enter ===
  const oldLabel = "labelText: '\u0627\u0644\u0646\u0642\u062f\u064a\u0629 \u0627\u0644\u0641\u0639\u0644\u064a\u0629',";
  const newLabel = "labelText: '\u0627\u0644\u0646\u0642\u062f\u064a\u0629 \u0627\u0644\u0641\u0639\u0644\u064a\u0629 (Enter \u0644\u0644\u0625\u063a\u0644\u0627\u0642)',";
  if (content.contains(oldLabel)) {
    content = content.replaceFirst(oldLabel, newLabel);
    print('Label updated.');
  } else {
    print('Label not found (skipping label change).');
  }

  file.writeAsStringSync(content);
  print('close_session_dialog.dart: Enter shortcut added.');
}
