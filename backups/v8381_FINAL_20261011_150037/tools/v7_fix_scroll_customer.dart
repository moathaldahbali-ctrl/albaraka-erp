import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\customer_picker_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_scroll_$ts').writeAsStringSync(content);

  if (content.contains('viewportDimension')) {
    print('Already patched, skipping.');
    return;
  }

  const oldMethod =
      '  void _scrollToSelected() {\n'
      '    if (!_scrollCtrl.hasClients) return;\n'
      '    const double itemHeight = 56.0;\n'
      '    final double maxScroll = _scrollCtrl.position.maxScrollExtent;\n'
      '    final double target = (_selectedIndex * itemHeight) - 100;\n'
      '    final double clamped =\n'
      '        target < 0 ? 0 : (target > maxScroll ? maxScroll : target);\n'
      '    _scrollCtrl.animateTo(\n'
      '      clamped,\n'
      '      duration: const Duration(milliseconds: 80),\n'
      '      curve: Curves.easeOut,\n'
      '    );\n'
      '  }';

  const newMethod =
      '  void _scrollToSelected() {\n'
      '    if (!_scrollCtrl.hasClients) return;\n'
      '    // v7.1: minimal-scroll + jumpTo (no lag on rapid arrow presses)\n'
      '    const double itemHeight = 57.0;\n'
      '    final double viewport = _scrollCtrl.position.viewportDimension;\n'
      '    final double offset = _scrollCtrl.offset;\n'
      '    final double itemTop = _selectedIndex * itemHeight;\n'
      '    final double itemBottom = itemTop + itemHeight;\n'
      '    double? newOffset;\n'
      '    if (itemTop < offset) {\n'
      '      newOffset = itemTop;\n'
      '    } else if (itemBottom > offset + viewport) {\n'
      '      newOffset = itemBottom - viewport;\n'
      '    }\n'
      '    if (newOffset == null) return;\n'
      '    final double maxScroll = _scrollCtrl.position.maxScrollExtent;\n'
      '    final double clamped =\n'
      '        newOffset < 0 ? 0 : (newOffset > maxScroll ? maxScroll : newOffset);\n'
      '    _scrollCtrl.jumpTo(clamped);\n'
      '  }';

  if (!content.contains(oldMethod)) {
    print('ERROR: _scrollToSelected method not found.');
    return;
  }

  content = content.replaceFirst(oldMethod, newMethod);

  const oldCall = '    _scrollToSelected();\n';
  const newCall = '    WidgetsBinding.instance.addPostFrameCallback((_) {\n'
      '      _scrollToSelected();\n'
      '    });\n';
  content = content.replaceFirst(oldCall, newCall);

  file.writeAsStringSync(content);
  print('customer_picker_dialog.dart: scroll fixed. Backup: .bak_scroll_$ts');
}
