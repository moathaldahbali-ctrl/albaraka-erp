import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\screens\sale_screen.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_arrows_$ts').writeAsStringSync(content);

  if (content.contains('_searchSelectedIndex')) {
    print('Already patched, skipping.');
    return;
  }

  // 1. Fields
  const fieldsAnchor = '  final FocusNode _customerFocus = FocusNode();';
  if (!content.contains(fieldsAnchor)) {
    print('ERROR: fields anchor not found.');
    return;
  }
  content = content.replaceFirst(fieldsAnchor,
      '${fieldsAnchor}\n'
      '  int _searchSelectedIndex = 0;\n'
      '  final ScrollController _searchScrollCtrl = ScrollController();');

  // 2. Dispose
  const disposeAnchor = '    _customerFocus.dispose();';
  if (!content.contains(disposeAnchor)) {
    print('ERROR: dispose anchor not found.');
    return;
  }
  content = content.replaceFirst(disposeAnchor,
      '${disposeAnchor}\n    _searchScrollCtrl.dispose();');

  // 3. Reset index in _loadProducts
  const loadAnchor =
      '      _searchResults = results;\n      _loadingProducts = false;';
  if (!content.contains(loadAnchor)) {
    print('ERROR: load anchor not found.');
    return;
  }
  content = content.replaceFirst(loadAnchor,
      '      _searchResults = results;\n'
      '      _searchSelectedIndex = 0;\n'
      '      _loadingProducts = false;');

  // 4. Use selected index in _submitFirstResult
  const submitAnchor = '    await _addToInvoice(_searchResults.first);';
  if (!content.contains(submitAnchor)) {
    print('ERROR: submit anchor not found.');
    return;
  }
  content = content.replaceFirst(submitAnchor,
      '    final idx =\n'
      '        _searchSelectedIndex.clamp(0, _searchResults.length - 1);\n'
      '    await _addToInvoice(_searchResults[idx]);');

  // 5. Add _moveSearchSelection method before _submitFirstResult
  const methodAnchor = '  Future<void> _submitFirstResult(String query) async {';
  if (!content.contains(methodAnchor)) {
    print('ERROR: method anchor not found.');
    return;
  }
  const newMethod = '''  void _moveSearchSelection(int delta) {
    if (_searchResults.isEmpty) return;
    setState(() {
      _searchSelectedIndex =
          (_searchSelectedIndex + delta).clamp(0, _searchResults.length - 1);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_searchScrollCtrl.hasClients) return;
      const itemHeight = 48.0;
      final target = _searchSelectedIndex * itemHeight;
      final maxScroll = _searchScrollCtrl.position.maxScrollExtent;
      _searchScrollCtrl.animateTo(
        target.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    });
  }

''';
  content = content.replaceFirst(methodAnchor, newMethod + methodAnchor);

  // 6a. Wrap TextField opening
  const openOld = '          Expanded(\n'
      '            child: TextField(\n'
      '              controller: _searchCtrl,';
  const openNew = '          Expanded(\n'
      '            child: CallbackShortcuts(\n'
      '              bindings: {\n'
      '                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>\n'
      '                    _moveSearchSelection(1),\n'
      '                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>\n'
      '                    _moveSearchSelection(-1),\n'
      '              },\n'
      '              child: Focus(\n'
      '                autofocus: false,\n'
      '                child: TextField(\n'
      '              controller: _searchCtrl,';
  if (!content.contains(openOld)) {
    print('ERROR: TextField open anchor not found.');
    return;
  }
  content = content.replaceFirst(openOld, openNew);

  // 6b. Wrap TextField closing
  const closeOld = '                border: OutlineInputBorder(\n'
      '                  borderRadius: BorderRadius.circular(8),\n'
      '                ),\n'
      '              ),\n'
      '            ),\n'
      '          ),\n'
      '          const SizedBox(width: 8),';
  const closeNew = '                border: OutlineInputBorder(\n'
      '                  borderRadius: BorderRadius.circular(8),\n'
      '                ),\n'
      '              ),\n'
      '            ),\n'
      '              ),\n'
      '            ),\n'
      '          ),\n'
      '          const SizedBox(width: 8),';
  if (!content.contains(closeOld)) {
    print('ERROR: TextField close anchor not found.');
    return;
  }
  content = content.replaceFirst(closeOld, closeNew);

  // 7. ListView: isFirst -> isSelected
  content = content.replaceFirst('final isFirst = i == 0;',
      'final isSelected = i == _searchSelectedIndex;');
  content = content.replaceFirst('selected: isFirst,', 'selected: isSelected,');
  content = content.replaceFirst('selectedTileColor: Colors.blue.shade50,',
      'selectedTileColor: Colors.orange.shade100,');
  content = content.replaceFirst(
      'isFirst ? Icons.keyboard_return : Icons.add_circle_outline,',
      'isSelected ? Icons.keyboard_return : Icons.add_circle_outline,');
  content = content.replaceFirst('color: isFirst ? Colors.blue : null,',
      'color: isSelected ? Colors.orange.shade800 : null,');

  // 8. Add ScrollController to ListView
  const listAnchor = ': ListView.builder(\n'
      '                  shrinkWrap: true,\n'
      '                  itemCount: _searchResults.length,';
  if (!content.contains(listAnchor)) {
    print('ERROR: ListView anchor not found.');
    return;
  }
  content = content.replaceFirst(listAnchor,
      ': ListView.builder(\n'
      '                  shrinkWrap: true,\n'
      '                  controller: _searchScrollCtrl,\n'
      '                  itemCount: _searchResults.length,');

  file.writeAsStringSync(content);
  print('sale_screen.dart: arrows navigation added. Backup: .bak_arrows_$ts');
}
