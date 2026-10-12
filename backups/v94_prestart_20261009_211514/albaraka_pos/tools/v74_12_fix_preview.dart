import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\services\receipt_service.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_preview_$ts').writeAsStringSync(content);

  if (content.contains('preview = save + open with viewer')) {
    print('Already patched, skipping.');
    return;
  }

  const startStr = '  static Future<void> previewPdf(';
  final startIdx = content.indexOf(startStr);
  if (startIdx < 0) {
    print('ERROR: previewPdf not found.');
    return;
  }

  const endStr = '\n  }\n';
  final endIdx = content.indexOf(endStr, startIdx);
  if (endIdx < 0) {
    print('ERROR: closing brace not found.');
    return;
  }

  const newPreview = '''  static Future<void> previewPdf(
      Uint8List bytes, String invoiceNumber) async {
    // v7.4/12: preview = save + open with viewer
    final dir = Directory(r'D:\\albaraka\\data\\receipts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final safeName = invoiceNumber.replaceAll(
        RegExp(r'[\\\\/:*?"<>|]'), '_');
    final file = File(p.join(dir.path, '\$safeName.pdf'));
    await file.writeAsBytes(bytes);
    await Process.run('cmd', ['/c', 'start', '', file.path]);
  }
''';

  final before = content.substring(0, startIdx);
  final after = content.substring(endIdx + endStr.length);

  file.writeAsStringSync(before + newPreview + after);
  print('receipt_service.dart: previewPdf patched.');
}
