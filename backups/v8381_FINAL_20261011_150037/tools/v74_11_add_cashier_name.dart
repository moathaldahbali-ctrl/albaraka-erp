import 'dart:io';

void main() {
  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  print('Backup suffix: .bak_$ts');

  _patchLocalDb(ts);
  _patchReceiptService(ts);
  _patchCloseSessionDialog(ts);
  _patchSaleScreen(ts);
  _patchMain(ts);

  print('ALL DONE.');
}

// ============================================================
void _patchLocalDb(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('getCurrentUserName')) {
    print('local_db.dart: already patched, skipping.');
    return;
  }

  const anchor = '  Future<Map<String, dynamic>> saveInvoice({';
  if (!content.contains(anchor)) {
    print('local_db.dart: ERROR - anchor not found.');
    return;
  }

  const methods = '  Future<String?> getCurrentUserName() async {\n'
      '    final userId = await _getCurrentUserId();\n'
      '    if (userId == null) return null;\n'
      '    final db = await database;\n'
      '    final rows = await db.query(\n'
      "      'users_local',\n"
      "      columns: ['display_name', 'username'],\n"
      "      where: 'id = ?',\n"
      "      whereArgs: [userId],\n"
      '      limit: 1,\n'
      '    );\n'
      '    if (rows.isEmpty) return null;\n'
      "    final r = rows.first;\n"
      "    final name = r['display_name'] ?? r['username'];\n"
      '    return name?.toString();\n'
      '  }\n'
      '\n';

  content = content.replaceFirst(anchor, methods + anchor);
  file.writeAsStringSync(content);
  print('local_db.dart: patched.');
}

// ============================================================
void _patchReceiptService(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\services\receipt_service.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('final String? cashierName;')) {
    print('receipt_service.dart: already patched, skipping.');
    return;
  }

  // 1. Add field
  const oldField = '  final String? customerName;';
  if (!content.contains(oldField)) {
    print('receipt_service.dart: ERROR - customerName field not found.');
    return;
  }
  content = content.replaceFirst(oldField,
      '  final String? customerName;\n  final String? cashierName;');

  // 2. Add constructor param
  const oldCtor = '    required this.customerName,';
  if (!content.contains(oldCtor)) {
    print('receipt_service.dart: ERROR - customerName ctor not found.');
    return;
  }
  content = content.replaceFirst(oldCtor,
      '    required this.customerName,\n    this.cashierName,');

  // 3. Add to PDF before _buildLinesTable
  const tableMarker = '              _buildLinesTable(data.lines),';
  if (!content.contains(tableMarker)) {
    print('receipt_service.dart: ERROR - table marker not found.');
    return;
  }
  const cashierBlock =
      "              if (data.cashierName != null &&\n"
      "                  data.cashierName!.isNotEmpty) ...[\n"
      "                pw.SizedBox(height: 4),\n"
      "                _infoLine('\u0627\u0644\u0643\u0627\u0634\u064a\u0631:',\n"
      "                    data.cashierName!),\n"
      "              ],\n";
  content = content.replaceFirst(tableMarker, cashierBlock + tableMarker);

  file.writeAsStringSync(content);
  print('receipt_service.dart: patched.');
}

// ============================================================
void _patchCloseSessionDialog(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('_cashierName')) {
    print('close_session_dialog.dart: already patched, skipping.');
    return;
  }

  // 1. Add field
  const fieldAnchor = '  String? _error;';
  if (!content.contains(fieldAnchor)) {
    print('close_session_dialog.dart: ERROR - _error anchor not found.');
    return;
  }
  content = content.replaceFirst(fieldAnchor,
      '  String? _error;\n  String? _cashierName;');

  // 2. Load user in _loadSummary (after getSessionSummary)
  final summaryRe = RegExp(
      r"final summary = await LocalDatabase\.instance\s*\n\s*\.getSessionSummary\(session\['id'\] as String\);");
  final summaryMatch = summaryRe.firstMatch(content);
  if (summaryMatch == null) {
    print('close_session_dialog.dart: ERROR - summary call not found.');
    return;
  }
  final insertAt = summaryMatch.end;
  const userLoad = '\n'
      '      final user = await LocalDatabase.instance.getCurrentUser();\n'
      '      final cashierName = user == null\n'
      '          ? null\n'
      "          : (user['display_name'] ?? user['username'])?.toString();";
  content = content.substring(0, insertAt) + userLoad + content.substring(insertAt);

  // 3. Set _cashierName in setState
  final setStateRe = RegExp(
      r'setState\(\(\) \{\s*\n\s*_summary = summary;\s*\n\s*_loading = false;\s*\n\s*\}\);');
  if (!setStateRe.hasMatch(content)) {
    print('close_session_dialog.dart: ERROR - setState block not found.');
    return;
  }
  content = content.replaceFirstMapped(setStateRe, (m) {
    return 'setState(() {\n'
        '        _summary = summary;\n'
        '        _cashierName = cashierName;\n'
        '        _loading = false;\n'
        '      });';
  });

  // 4. Add row before 'عدد الفواتير' row
  final rowAnchor = "_row('\u0639\u062f\u062f \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631'";
  final rowIdx = content.indexOf(rowAnchor);
  if (rowIdx < 0) {
    print('close_session_dialog.dart: ERROR - invoice count row not found.');
    return;
  }
  final lineStart = content.lastIndexOf('\n', rowIdx) + 1;
  const newRow = "          if (_cashierName != null)\n"
      "            _row('\u0627\u0644\u0643\u0627\u0634\u064a\u0631', _cashierName!),\n";
  content = content.substring(0, lineStart) + newRow + content.substring(lineStart);

  file.writeAsStringSync(content);
  print('close_session_dialog.dart: patched.');
}

// ============================================================
void _patchSaleScreen(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\screens\sale_screen.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('cashierName: cashierName,')) {
    print('sale_screen.dart: already patched, skipping.');
    return;
  }

  // 1. Change _buildReceiptData signature to async
  const oldSig = 'ReceiptData _buildReceiptData({';
  if (!content.contains(oldSig)) {
    print('sale_screen.dart: ERROR - _buildReceiptData signature not found.');
    return;
  }
  content = content.replaceFirst(oldSig, 'Future<ReceiptData> _buildReceiptData({');

  // 2. Add async + cashier load
  const oldBody = '  }) {\n    return ReceiptData(';
  if (!content.contains(oldBody)) {
    print('sale_screen.dart: ERROR - _buildReceiptData body not found.');
    return;
  }
  content = content.replaceFirst(oldBody,
      '  }) async {\n'
      '    final cashierName = await LocalDatabase.instance.getCurrentUserName();\n'
      '    return ReceiptData(');

  // 3. Add cashierName to constructor call
  const linesAnchor = '      lines: _invoice';
  if (!content.contains(linesAnchor)) {
    print('sale_screen.dart: ERROR - lines anchor not found.');
    return;
  }
  content = content.replaceFirst(linesAnchor,
      '      cashierName: cashierName,\n' + linesAnchor);

  // 4. Update callers
  content = content.replaceAll(
      'final data = _buildReceiptData(', 'final data = await _buildReceiptData(');
  content = content.replaceAll(
      'final savedData = _buildReceiptData(',
      'final savedData = await _buildReceiptData(');

  file.writeAsStringSync(content);
  print('sale_screen.dart: patched.');
}

// ============================================================
void _patchMain(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\main.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_$ts').writeAsStringSync(content);

  if (content.contains('_loadCashierName')) {
    print('main.dart: already patched, skipping.');
    return;
  }

  const titleMarker = "        title: const Text('"
      "\u0628\u0642\u0627\u0644\u0629 \u0648\u0628\u0647\u0627\u0631\u0627\u062a "
      "\u0627\u0644\u0628\u0631\u0643\u0629'),";
  final titleIdx = content.indexOf(titleMarker);
  if (titleIdx < 0) {
    print('main.dart: ERROR - title marker not found.');
    return;
  }

  final classRe = RegExp(r'class\s+_\w+State\s+extends\s+State<');
  int lastEnd = -1;
  for (final m in classRe.allMatches(content)) {
    if (m.start < titleIdx) lastEnd = m.end;
    else break;
  }
  if (lastEnd < 0) {
    print('main.dart: ERROR - no State class before title.');
    return;
  }
  final braceIdx = content.indexOf('{', lastEnd);
  if (braceIdx < 0) {
    print('main.dart: ERROR - no class opening brace.');
    return;
  }
  final classBodyStart = braceIdx + 1;

  final nextClassMatch =
      RegExp(r'\nclass\s+').firstMatch(content.substring(classBodyStart));
  final classBodyEnd = nextClassMatch == null
      ? content.length
      : classBodyStart + nextClassMatch.start;
  final classBody = content.substring(classBodyStart, classBodyEnd);
  final hasInitState = classBody.contains('void initState()');

  const fieldAndMethod = '\n'
      '  String? _cashierName;\n'
      '\n'
      '  Future<void> _loadCashierName() async {\n'
      '    final n = await LocalDatabase.instance.getCurrentUserName();\n'
      '    if (mounted) setState(() => _cashierName = n);\n'
      '  }\n';

  String newContent = content;

  if (hasInitState) {
    const superStr = 'super.initState();';
    final superIdx = newContent.indexOf(superStr, classBodyStart);
    if (superIdx < 0 || superIdx >= classBodyEnd) {
      print('main.dart: ERROR - super.initState() not found.');
      return;
    }
    final insertCallAt = superIdx + superStr.length;
    newContent = newContent.substring(0, insertCallAt) +
        '\n    _loadCashierName();' +
        newContent.substring(insertCallAt);
    newContent = newContent.substring(0, classBodyStart) +
        fieldAndMethod +
        newContent.substring(classBodyStart);
  } else {
    const initBlock = '\n'
        '  @override\n'
        '  void initState() {\n'
        '    super.initState();\n'
        '    _loadCashierName();\n'
        '  }\n';
    newContent = newContent.substring(0, classBodyStart) +
        fieldAndMethod +
        initBlock +
        newContent.substring(classBodyStart);
  }

  final newTitleIdx = newContent.indexOf(titleMarker);
  if (newTitleIdx < 0) {
    print('main.dart: ERROR - title lost after edits.');
    return;
  }

  const newTitle = "        title: Column(\n"
      "          mainAxisSize: MainAxisSize.min,\n"
      "          children: [\n"
      "            const Text('"
      "\u0628\u0642\u0627\u0644\u0629 \u0648\u0628\u0647\u0627\u0631\u0627\u062a "
      "\u0627\u0644\u0628\u0631\u0643\u0629',\n"
      "                style: TextStyle(fontSize: 17)),\n"
      "            if (_cashierName != null && _cashierName!.isNotEmpty)\n"
      "              Text('"
      "\u0627\u0644\u0643\u0627\u0634\u064a\u0631: "
      r"$_cashierName"
      "',\n"
      "                  style: TextStyle(fontSize: 11)),\n"
      "          ],\n"
      "        ),";

  newContent = newContent.replaceRange(
      newTitleIdx, newTitleIdx + titleMarker.length, newTitle);

  file.writeAsStringSync(newContent);
  print('main.dart: patched.');
}
