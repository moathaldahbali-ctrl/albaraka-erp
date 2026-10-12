import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.fix_$ts').writeAsStringSync(content);

  if (!content.contains('getCurrentUser()')) {
    print('No getCurrentUser() call found. Nothing to fix.');
    return;
  }

  content = content.replaceAll(
      'LocalDatabase.instance.getCurrentUser()',
      'LocalDatabase.instance.getCurrentUserName()');

  file.writeAsStringSync(content);
  print('close_session_dialog.dart: fixed.');
}
