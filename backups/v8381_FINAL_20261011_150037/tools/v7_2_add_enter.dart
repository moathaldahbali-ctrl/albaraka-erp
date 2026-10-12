import 'dart:io';

void main() {
  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);

  _patch(r'D:\albaraka\albaraka_pos\lib\widgets\product_picker_dialog.dart', ts);
  _patch(r'D:\albaraka\albaraka_pos\lib\widgets\customer_picker_dialog.dart', ts);

  print('DONE.');
}

void _patch(String path, String ts) {
  final file = File(path);
  var content = file.readAsStringSync();
  File('${file.path}.bak_enter_$ts').writeAsStringSync(content);

  final name = file.uri.pathSegments.last;

  if (content.contains('LogicalKeyboardKey.enter)')) {
    print('$name: already patched, skipping.');
    return;
  }

  const oldBlock =
      '        const SingleActivator(LogicalKeyboardKey.numpadEnter):\n'
      '            _confirmSelected,';

  const newBlock =
      '        const SingleActivator(LogicalKeyboardKey.enter):\n'
      '            _confirmSelected,\n'
      '        const SingleActivator(LogicalKeyboardKey.numpadEnter):\n'
      '            _confirmSelected,';

  if (!content.contains(oldBlock)) {
    print('$name: ERROR - anchor not found.');
    return;
  }

  content = content.replaceFirst(oldBlock, newBlock);
  file.writeAsStringSync(content);
  print('$name: enter key added.');
}
