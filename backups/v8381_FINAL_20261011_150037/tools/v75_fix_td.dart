import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.fix_td_$ts').writeAsStringSync(content);

  const old = "import 'package:intl/intl.dart';";
  const neu = "import 'package:intl/intl.dart' hide TextDirection;";

  if (content.contains(neu)) {
    print('Already fixed, skipping.');
    return;
  }
  if (!content.contains(old)) {
    print('ERROR: intl import not found.');
    return;
  }

  content = content.replaceFirst(old, neu);
  file.writeAsStringSync(content);
  print('close_session_dialog.dart: TextDirection conflict fixed.');
}
