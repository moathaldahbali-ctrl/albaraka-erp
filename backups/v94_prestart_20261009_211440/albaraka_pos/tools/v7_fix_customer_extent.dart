import 'dart:io';

void main() {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\customer_picker_dialog.dart');
  var content = file.readAsStringSync();

  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  File('${file.path}.bak_fixedext_$ts').writeAsStringSync(content);

  if (content.contains('itemExtent: 66')) {
    print('Already patched, skipping.');
    return;
  }

  // 1. Replace ListView.separated with ListView.builder + itemExtent
  const oldList = '                    : ListView.separated(\n'
      '                        controller: _scrollCtrl,\n'
      '                        itemCount: _filtered.length,\n'
      '                        separatorBuilder: (_, __) => const Divider(height: 1),\n'
      '                        itemBuilder: (context, i) {';

  const newList = '                    : ListView.builder(\n'
      '                        controller: _scrollCtrl,\n'
      '                        itemCount: _filtered.length,\n'
      '                        itemExtent: 66,\n'
      '                        itemBuilder: (context, i) {';

  if (!content.contains(oldList)) {
    print('ERROR: ListView.separated block not found.');
    return;
  }
  content = content.replaceFirst(oldList, newList);

  // 2. Wrap list item Container with border to compensate for missing separators
  const oldContainer = '                          return Container(\n'
      '                            color: isSelected ? Colors.blue.shade50 : null,\n'
      '                            child: ListTile(';

  const newContainer = '                          return Container(\n'
      '                            decoration: BoxDecoration(\n'
      '                              color: isSelected ? Colors.blue.shade50 : null,\n'
      '                              border: Border(\n'
      '                                  bottom: BorderSide(\n'
      '                                      color: Colors.grey.shade300,\n'
      '                                      width: 0.5)),\n'
      '                            ),\n'
      '                            child: ListTile(';

  if (!content.contains(oldContainer)) {
    print('ERROR: Container block not found.');
    return;
  }
  content = content.replaceFirst(oldContainer, newContainer);

  // 3. Update itemHeight in _scrollToSelected to 66
  const oldHeight = '    const double itemHeight = 57.0;';
  const newHeight = '    const double itemHeight = 66.0;';
  if (!content.contains(oldHeight)) {
    print('ERROR: itemHeight not found.');
    return;
  }
  content = content.replaceFirst(oldHeight, newHeight);

  file.writeAsStringSync(content);
  print('customer_picker_dialog.dart: itemExtent 66 applied. Backup: .bak_fixedext_$ts');
}
