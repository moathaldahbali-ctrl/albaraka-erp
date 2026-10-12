import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('activeSessionId')) {
    print('local_db.dart: already patched, skipping.');
    return;
  }

  const anchor = 'final effectiveCashierId = cashierId ?? await _getCurrentUserId();';
  final anchorIdx = content.indexOf(anchor);
  if (anchorIdx < 0) {
    print('ERROR: anchor not found.');
    exit(1);
  }
  final eol = content.indexOf('\n', anchorIdx) + 1;

  const insertion = '''
    final activeSession = await getActiveSession();
    if (activeSession == null) {
      throw Exception('\\u0644\\u0627 \\u062a\\u0648\\u062c\\u062f \\u0648\\u0631\\u062f\\u064a\\u0629 \\u0645\\u0641\\u062a\\u0648\\u062d\\u0629');
    }
    final activeSessionId = activeSession['id'] as String;
''';

  content = content.substring(0, eol) + insertion + '\n' + content.substring(eol);

  const oldSession = "'register_session_id': '44444444-4444-4444-4444-444444444444',";
  const newSession = "'register_session_id': activeSessionId,";
  if (!content.contains(oldSession)) {
    print('ERROR: hardcoded session UUID not found.');
    exit(1);
  }
  content = content.replaceFirst(oldSession, newSession);

  file.writeAsStringSync(content);
  print('local_db.dart: patched. Backup suffix: .bak_$ts');
}
