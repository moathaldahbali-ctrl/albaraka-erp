import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\services\receipt_service.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_a4_$ts').writeAsStringSync(content);

  const old = 'pageFormat: PdfPageFormat.a5,';
  const neu = 'pageFormat: PdfPageFormat.a4,';

  if (content.contains(neu)) {
    print('Already A4, skipping.');
    return;
  }
  if (!content.contains(old)) {
    print('ERROR: PdfPageFormat.a5 not found.');
    return;
  }

  content = content.replaceFirst(old, neu);
  file.writeAsStringSync(content);
  print('receipt_service.dart: switched A5 -> A4.');
}
