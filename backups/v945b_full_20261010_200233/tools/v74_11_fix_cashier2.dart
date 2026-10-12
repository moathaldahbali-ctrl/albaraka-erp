import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.fix2_$ts').writeAsStringSync(content);

  const oldBlock =
      '      final user = await LocalDatabase.instance.getCurrentUserName();\n'
      '      final cashierName = user == null\n'
      '          ? null\n'
      "          : (user['display_name'] ?? user['username'])?.toString();";

  const newBlock =
      '      final cashierName =\n'
      '          await LocalDatabase.instance.getCurrentUserName();';

  if (!content.contains(oldBlock)) {
    print('Old block not found. Checking alternatives...');
    final re = RegExp(
        r"final user = await LocalDatabase\.instance\.getCurrentUserName\(\);[\s\S]*?\.toString\(\);");
    if (!re.hasMatch(content)) {
      print('ERROR: cannot locate block.');
      return;
    }
    content = content.replaceFirst(re, newBlock);
    print('Pattern-replaced.');
  } else {
    content = content.replaceFirst(oldBlock, newBlock);
    print('Block replaced.');
  }

  file.writeAsStringSync(content);
  print('close_session_dialog.dart: fixed.');
}
