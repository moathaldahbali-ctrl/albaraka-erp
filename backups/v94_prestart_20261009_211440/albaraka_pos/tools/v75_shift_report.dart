import 'dart:io';

void main() {
  final ts = DateTime.now().toIso8601String()
      .replaceAll(RegExp(r'[:.\-T]'), '').substring(0, 14);
  print('Backup suffix: .bak_v75_$ts');

  _patchLocalDb(ts);
  _patchReceiptService(ts);
  _patchCloseDialog(ts);

  print('ALL DONE.');
}

void _patchLocalDb(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\db\local_db.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_v75_$ts').writeAsStringSync(content);

  if (content.contains('getSessionInvoices')) {
    print('local_db.dart: already patched, skipping.');
    return;
  }

  const anchor = '  Future<Map<String, dynamic>> getSessionSummary(';
  if (!content.contains(anchor)) {
    print('local_db.dart: ERROR - anchor not found.');
    return;
  }

  const method = '  Future<List<Map<String, dynamic>>> getSessionInvoices(\n'
      '      String sessionId) async {\n'
      '    final db = await database;\n'
      '    return db.query(\n'
      "      'sales_local',\n"
      "      columns: [\n"
      "        'invoice_number', 'occurred_at', 'payment_method',\n"
      "        'total', 'customer_name',\n"
      '      ],\n'
      "      where: 'register_session_id = ?',\n"
      '      whereArgs: [sessionId],\n'
      "      orderBy: 'occurred_at ASC',\n"
      '    );\n'
      '  }\n'
      '\n';

  content = content.replaceFirst(anchor, method + anchor);
  file.writeAsStringSync(content);
  print('local_db.dart: patched.');
}

void _patchReceiptService(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\services\receipt_service.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_v75_$ts').writeAsStringSync(content);

  if (content.contains('generateSessionPdf')) {
    print('receipt_service.dart: already patched, skipping.');
    return;
  }

  const classAnchor = 'class ReceiptService {';
  if (!content.contains(classAnchor)) {
    print('receipt_service.dart: ERROR - class anchor not found.');
    return;
  }

  const newClasses = '''
class SessionInvoice {
  final String invoiceNumber;
  final DateTime occurredAt;
  final String paymentMethod;
  final double total;
  final String? customerName;

  SessionInvoice({
    required this.invoiceNumber,
    required this.occurredAt,
    required this.paymentMethod,
    required this.total,
    this.customerName,
  });
}

class SessionData {
  final String cashierName;
  final DateTime openedAt;
  final DateTime closedAt;
  final double openingCash;
  final double expectedCash;
  final double closingCash;
  final double difference;
  final String? notes;
  final int invoiceCount;
  final double totalSales;
  final double cashSales;
  final double creditSales;
  final List<SessionInvoice> invoices;

  SessionData({
    required this.cashierName,
    required this.openedAt,
    required this.closedAt,
    required this.openingCash,
    required this.expectedCash,
    required this.closingCash,
    required this.difference,
    required this.notes,
    required this.invoiceCount,
    required this.totalSales,
    required this.cashSales,
    required this.creditSales,
    required this.invoices,
  });
}

''';

  content = content.replaceFirst(classAnchor, newClasses + classAnchor);

  final methodAnchor = '  static String _fmtNum(double v) {';
  if (!content.contains(methodAnchor)) {
    print('receipt_service.dart: ERROR - _fmtNum anchor not found.');
    return;
  }

  const pdfMethod = '''
  static Future<Uint8List> generateSessionPdf(SessionData data) async {
    final font = await PdfGoogleFonts.cairoRegular();
    final fontBold = await PdfGoogleFonts.cairoBold();

    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo_bw.png');
      logo = pw.MemoryImage(logoBytes.buffer
          .asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes));
    } catch (_) {
      logo = null;
    }

    final doc = pw.Document();
    final dtFmt = DateFormat('dd/MM/yyyy HH:mm');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              if (logo != null) ...[
                pw.Center(child: pw.Image(logo, height: 60)),
                pw.SizedBox(height: 4),
              ],
              pw.Center(
                child: pw.Text(_shopName,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                  child: pw.Text(_shopAddressLine1,
                      style: const pw.TextStyle(fontSize: 9))),
              pw.Center(
                  child: pw.Text(_shopAddressLine2,
                      style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(height: 2),
              pw.Center(
                  child: pw.Text('\\u0647\\u0627\\u062a\\u0641: ' + _shopPhone,
                      style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                    '\\u062a\\u0642\\u0631\\u064a\\u0631 \\u0625\\u063a\\u0644\\u0627\\u0642 \\u0627\\u0644\\u0648\\u0631\\u062f\\u064a\\u0629',
                    style: pw.TextStyle(
                        fontSize: 15, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              _infoLine('\\u0627\\u0644\\u0643\\u0627\\u0634\\u064a\\u0631:',
                  data.cashierName),
              pw.SizedBox(height: 3),
              _infoLine('\\u0648\\u0642\\u062a \\u0627\\u0644\\u0641\\u062a\\u062d:',
                  dtFmt.format(data.openedAt)),
              pw.SizedBox(height: 3),
              _infoLine('\\u0648\\u0642\\u062a \\u0627\\u0644\\u0625\\u063a\\u0644\\u0627\\u0642:',
                  dtFmt.format(data.closedAt)),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\\u0645\\u0644\\u062e\\u0635 \\u0627\\u0644\\u0648\\u0631\\u062f\\u064a\\u0629',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),
              _infoLine('\\u0639\\u062f\\u062f \\u0627\\u0644\\u0641\\u0648\\u0627\\u062a\\u064a\\u0631:',
                  data.invoiceCount.toString()),
              pw.SizedBox(height: 3),
              _infoLine('\\u0625\\u062c\\u0645\\u0627\\u0644\\u064a \\u0627\\u0644\\u0645\\u0628\\u064a\\u0639\\u0627\\u062a:',
                  _fmtNum(data.totalSales) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\\u0645\\u0646\\u0647\\u0627 \\u0646\\u0642\\u062f:',
                  _fmtNum(data.cashSales) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\\u0645\\u0646\\u0647\\u0627 \\u0622\\u062c\\u0644:',
                  _fmtNum(data.creditSales) + ' ' + _currency),
              pw.SizedBox(height: 6),
              _infoLine('\\u0627\\u0644\\u0646\\u0642\\u062f\\u064a\\u0629 \\u0639\\u0646\\u062f \\u0627\\u0644\\u0641\\u062a\\u062d:',
                  _fmtNum(data.openingCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\\u0627\\u0644\\u0645\\u062a\\u0648\\u0642\\u0639 \\u0641\\u064a \\u0627\\u0644\\u0635\\u0646\\u062f\\u0648\\u0642:',
                  _fmtNum(data.expectedCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\\u0627\\u0644\\u0646\\u0642\\u062f\\u064a\\u0629 \\u0627\\u0644\\u0641\\u0639\\u0644\\u064a\\u0629:',
                  _fmtNum(data.closingCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\\u0627\\u0644\\u0641\\u0631\\u0642:',
                  _fmtNum(data.difference) + ' ' + _currency),
              if (data.notes != null && data.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                _infoLine('\\u0645\\u0644\\u0627\\u062d\\u0638\\u0627\\u062a:', data.notes!),
              ],
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\\u062a\\u0641\\u0627\\u0635\\u064a\\u0644 \\u0627\\u0644\\u0641\\u0648\\u0627\\u062a\\u064a\\u0631 (' +
                        data.invoices.length.toString() +
                        ')',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),
              _buildInvoicesTable(data.invoices),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                    '\\u0646\\u0647\\u0627\\u064a\\u0629 \\u0627\\u0644\\u062a\\u0642\\u0631\\u064a\\u0631',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  static pw.Widget _buildInvoicesTable(List<SessionInvoice> invoices) {
    if (invoices.isEmpty) {
      return pw.Center(
        child: pw.Text('\\u0644\\u0627 \\u062a\\u0648\\u062c\\u062f \\u0641\\u0648\\u0627\\u062a\\u064a\\u0631',
            style: const pw.TextStyle(fontSize: 10)),
      );
    }

    // RTL: reverse physical column order.
    // Desired RTL reading: time, invoice, method, customer, total
    // Physical order (leftmost first): total, customer, method, invoice, time
    final headers = [
      '\\u0627\\u0644\\u0625\\u062c\\u0645\\u0627\\u0644\\u064a',
      '\\u0627\\u0644\\u0639\\u0645\\u064a\\u0644',
      '\\u0637\\u0631\\u064a\\u0642\\u0629 \\u0627\\u0644\\u062f\\u0641\\u0639',
      '\\u0631\\u0642\\u0645 \\u0627\\u0644\\u0641\\u0627\\u062a\\u0648\\u0631\\u0629',
      '\\u0627\\u0644\\u0648\\u0642\\u062a',
    ];

    final rows = invoices.map((inv) {
      return [
        _fmtNum(inv.total),
        (inv.customerName ?? '-'),
        inv.paymentMethod == 'cash'
            ? '\\u0646\\u0642\\u062f'
            : '\\u0622\\u062c\\u0644',
        inv.invoiceNumber,
        DateFormat('HH:mm').format(inv.occurredAt),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: rows,
      headerStyle:
          pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headerDecoration:
          const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.center,
      headerAlignment: pw.Alignment.center,
      border: pw.TableBorder.all(width: 0.3, color: PdfColors.grey600),
    );
  }
''';

  content = content.replaceFirst(methodAnchor, pdfMethod + '\n' + methodAnchor);
  file.writeAsStringSync(content);
  print('receipt_service.dart: patched.');
}

void _patchCloseDialog(String ts) {
  final file = File(r'D:\albaraka\albaraka_pos\lib\widgets\close_session_dialog.dart');
  var content = file.readAsStringSync();
  File('${file.path}.bak_v75_$ts').writeAsStringSync(content);

  if (content.contains('generateSessionPdf')) {
    print('close_session_dialog.dart: already patched, skipping.');
    return;
  }

  // 1. Add imports
  const importAnchor = "import '../db/local_db.dart';";
  if (!content.contains(importAnchor)) {
    print('close_session_dialog.dart: ERROR - db import not found.');
    return;
  }
  content = content.replaceFirst(importAnchor,
      "import '../db/local_db.dart';\n"
      "import '../services/receipt_service.dart';\n"
      "import 'package:intl/intl.dart';");

  // 2. Insert report generation after closeSession
  const closeAnchor = '        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),\n      );';
  if (!content.contains(closeAnchor)) {
    print('close_session_dialog.dart: ERROR - closeSession block not found.');
    return;
  }

  const reportBlock = '''
      // v7.5: generate shift report PDF
      try {
        final reportSummary = await LocalDatabase.instance
            .getSessionSummary(session['id'] as String);
        final invoices = await LocalDatabase.instance
            .getSessionInvoices(session['id'] as String);
        final cashierName =
            await LocalDatabase.instance.getCurrentUserName() ?? '\\u063a\\u064a\\u0631 \\u0645\\u0639\\u0631\\u0648\\u0641';
        final sessionRow =
            reportSummary['session'] as Map<String, dynamic>;

        final sessionData = SessionData(
          cashierName: cashierName,
          openedAt: DateTime.parse(sessionRow['opened_at'] as String),
          closedAt: DateTime.now(),
          openingCash: (reportSummary['opening_cash'] as num).toDouble(),
          expectedCash:
              (reportSummary['expected_cash'] as num).toDouble(),
          closingCash: _closingCash,
          difference:
              _closingCash - (reportSummary['expected_cash'] as num).toDouble(),
          notes: _notesCtrl.text.trim().isEmpty
              ? null
              : _notesCtrl.text.trim(),
          invoiceCount: (reportSummary['invoice_count'] as num).toInt(),
          totalSales: (reportSummary['total_sales'] as num).toDouble(),
          cashSales: (reportSummary['cash_sales'] as num).toDouble(),
          creditSales: (reportSummary['credit_sales'] as num).toDouble(),
          invoices: invoices.map((row) {
            return SessionInvoice(
              invoiceNumber: row['invoice_number'] as String,
              occurredAt: DateTime.parse(row['occurred_at'] as String),
              paymentMethod:
                  (row['payment_method'] as String?) ?? 'cash',
              total: (row['total'] as num).toDouble(),
              customerName: row['customer_name'] as String?,
            );
          }).toList(),
        );

        final bytes =
            await ReceiptService.generateSessionPdf(sessionData);
        final reportName =
            'Shift-' + DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
        await ReceiptService.previewPdf(bytes, reportName);
      } catch (e) {
        debugPrint('Shift report generation failed: ' + e.toString());
      }
''';

  content = content.replaceFirst(closeAnchor, closeAnchor + reportBlock);
  file.writeAsStringSync(content);
  print('close_session_dialog.dart: patched.');
}
