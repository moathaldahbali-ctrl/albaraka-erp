import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class ReceiptLine {
  final String productName;
  final String sku;
  final String unitCode;
  final double quantity;
  final double unitPrice;
  final double subtotal;

  ReceiptLine({
    required this.productName,
    required this.sku,
    required this.unitCode,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
}

class ReceiptData {
  final String invoiceNumber;
  final DateTime occurredAt;
  final String paymentMethod;
  final String? customerName;
  final String? cashierName;
  final double total;
  final double paidAmount;
  final double changeAmount;
  final List<ReceiptLine> lines;

  ReceiptData({
    required this.invoiceNumber,
    required this.occurredAt,
    required this.paymentMethod,
    required this.customerName,
    this.cashierName,
    required this.total,
    this.paidAmount = 0,
    this.changeAmount = 0,
    required this.lines,
  });
}

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

// =============================================================================
// v9.4.6: خطوط PDF محلية (بدل Google Fonts — تعمل Offline)
// =============================================================================
pw.Font? _cachedCairoRegular;
pw.Font? _cachedCairoBold;

Future<pw.Font> _loadCairoRegular() async {
  if (_cachedCairoRegular != null) return _cachedCairoRegular!;
  final data = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
  _cachedCairoRegular = pw.Font.ttf(data);
  return _cachedCairoRegular!;
}

Future<pw.Font> _loadCairoBold() async {
  if (_cachedCairoBold != null) return _cachedCairoBold!;
  final data = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
  _cachedCairoBold = pw.Font.ttf(data);
  return _cachedCairoBold!;
}
class ReceiptService {
  static const String _shopName = 'بقالة وبهارات البركة';
  static const String _shopAddressLine1 = 'صنعاء - ش بيحان المتفرع من';
  static const String _shopAddressLine2 = 'ش 22 مايو';
  static const String _shopPhone = '772025928';
  static const String _currency = 'YER';

  static Future<Uint8List> generatePdf(ReceiptData data) async {
    final font = await _loadCairoRegular();
    final fontBold = await _loadCairoBold();

    // تحميل الشعار (أبيض/أسود)
    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo_bw.png');
      logo = pw.MemoryImage(logoBytes.buffer
          .asUint8List(logoBytes.offsetInBytes, logoBytes.lengthInBytes));
    } catch (_) {
      logo = null;
    }

    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ===== الشعار =====
              if (logo != null) ...[
                pw.Center(child: pw.Image(logo, height: 70)),
                pw.SizedBox(height: 6),
              ],
              pw.Center(
                child: pw.Text(
                  _shopName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(_shopAddressLine1,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.Center(
                child: pw.Text(_shopAddressLine2,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text('هاتف: ' + _shopPhone,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),

              // ===== معلومات الفاتورة (RTL بحت) =====
              _infoLine(
                'التاريخ:',
                DateFormat('dd/MM/yyyy HH:mm').format(data.occurredAt),
              ),
              pw.SizedBox(height: 4),
              _infoLine('الفاتورة:', data.invoiceNumber),
              pw.SizedBox(height: 4),
              _infoLine('طريقة الدفع:',
                  data.paymentMethod == 'cash' ? 'نقد' : 'أجل'),
              if (data.customerName != null &&
                  data.customerName!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _infoLine('العميل:', data.customerName!),
              ],

              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),

              if (data.cashierName != null &&
                  data.cashierName!.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                _infoLine('الكاشير:',
                    data.cashierName!),
              ],
              _buildLinesTable(data.lines),

              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),

              // ===== الإجمالي (RTL) =====
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.RichText(
                  textDirection: pw.TextDirection.rtl,
                  text: pw.TextSpan(
                    children: [
                      pw.TextSpan(
                        text: 'الإجمالي: ',
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.TextSpan(
                        text: _fmtNum(data.total) + ' ' + _currency,
                        style: pw.TextStyle(
                          fontSize: 15,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 8),

              pw.Center(
                child: pw.Text(
                  'شكراً لتسوقكم معنا',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(_shopName,
                    style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  /// سطر معلومات RTL: التسمية (bold) ثم القيمة، كلها من الحافة اليمنى.
  static pw.Widget _infoLine(String label, String value) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.RichText(
        textDirection: pw.TextDirection.rtl,
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: label + ' ',
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildLinesTable(List<ReceiptLine> lines) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        // ترتيب فيزيائي: من اليسار إلى اليمين في الكود
        // لأن RTL يُظهرها معكوسة.
        0: const pw.FlexColumnWidth(2), // الإجمالي (يظهر يسار)
        1: const pw.FlexColumnWidth(2), // السعر
        2: const pw.FlexColumnWidth(1.5), // الوحدة
        3: const pw.FlexColumnWidth(1.5), // الكمية
        4: const pw.FlexColumnWidth(4), // الصنف (يظهر يمين)
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('الإجمالي', bold: true),
            _cell('السعر', bold: true),
            _cell('الوحدة', bold: true),
            _cell('الكمية', bold: true),
            _cell('الصنف', bold: true),
          ],
        ),
        ...lines.map(
          (l) => pw.TableRow(
            children: [
              _cell(_fmtNum(l.subtotal)),
              _cell(_fmtNum(l.unitPrice)),
              _cell(l.unitCode),
              _cell(_fmtNum(l.quantity)),
              _cell(l.productName, align: pw.TextAlign.right),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _cell(
    String text, {
    bool bold = false,
    pw.TextAlign align = pw.TextAlign.center,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  static Future<Uint8List> generateSessionPdf(SessionData data) async {
    final font = await _loadCairoRegular();
    final fontBold = await _loadCairoBold();

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
                  child: pw.Text('\u0647\u0627\u062a\u0641: ' + _shopPhone,
                      style: const pw.TextStyle(fontSize: 9))),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                    '\u062a\u0642\u0631\u064a\u0631 \u0625\u063a\u0644\u0627\u0642 \u0627\u0644\u0648\u0631\u062f\u064a\u0629',
                    style: pw.TextStyle(
                        fontSize: 15, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 8),
              _infoLine('\u0627\u0644\u0643\u0627\u0634\u064a\u0631:',
                  data.cashierName),
              pw.SizedBox(height: 3),
              _infoLine('\u0648\u0642\u062a \u0627\u0644\u0641\u062a\u062d:',
                  dtFmt.format(data.openedAt)),
              pw.SizedBox(height: 3),
              _infoLine('\u0648\u0642\u062a \u0627\u0644\u0625\u063a\u0644\u0627\u0642:',
                  dtFmt.format(data.closedAt)),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\u0645\u0644\u062e\u0635 \u0627\u0644\u0648\u0631\u062f\u064a\u0629',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),
              _infoLine('\u0639\u062f\u062f \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631:',
                  data.invoiceCount.toString()),
              pw.SizedBox(height: 3),
              _infoLine('\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0645\u0628\u064a\u0639\u0627\u062a:',
                  _fmtNum(data.totalSales) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\u0645\u0646\u0647\u0627 \u0646\u0642\u062f:',
                  _fmtNum(data.cashSales) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\u0645\u0646\u0647\u0627 \u0622\u062c\u0644:',
                  _fmtNum(data.creditSales) + ' ' + _currency),
              pw.SizedBox(height: 6),
              _infoLine('\u0627\u0644\u0646\u0642\u062f\u064a\u0629 \u0639\u0646\u062f \u0627\u0644\u0641\u062a\u062d:',
                  _fmtNum(data.openingCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\u0627\u0644\u0645\u062a\u0648\u0642\u0639 \u0641\u064a \u0627\u0644\u0635\u0646\u062f\u0648\u0642:',
                  _fmtNum(data.expectedCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\u0627\u0644\u0646\u0642\u062f\u064a\u0629 \u0627\u0644\u0641\u0639\u0644\u064a\u0629:',
                  _fmtNum(data.closingCash) + ' ' + _currency),
              pw.SizedBox(height: 3),
              _infoLine('\u0627\u0644\u0641\u0631\u0642:',
                  _fmtNum(data.difference) + ' ' + _currency),
              if (data.notes != null && data.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 6),
                _infoLine('\u0645\u0644\u0627\u062d\u0638\u0627\u062a:', data.notes!),
              ],
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.7),
              pw.SizedBox(height: 6),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\u062a\u0641\u0627\u0635\u064a\u0644 \u0627\u0644\u0641\u0648\u0627\u062a\u064a\u0631 (' +
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
                    '\u0646\u0647\u0627\u064a\u0629 \u0627\u0644\u062a\u0642\u0631\u064a\u0631',
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
        child: pw.Text('\u0644\u0627 \u062a\u0648\u062c\u062f \u0641\u0648\u0627\u062a\u064a\u0631',
            style: const pw.TextStyle(fontSize: 10)),
      );
    }

    // RTL: reverse physical column order.
    // Desired RTL reading: time, invoice, method, customer, total
    // Physical order (leftmost first): total, customer, method, invoice, time
    final headers = [
      '\u0627\u0644\u0625\u062c\u0645\u0627\u0644\u064a',
      '\u0627\u0644\u0639\u0645\u064a\u0644',
      '\u0637\u0631\u064a\u0642\u0629 \u0627\u0644\u062f\u0641\u0639',
      '\u0631\u0642\u0645 \u0627\u0644\u0641\u0627\u062a\u0648\u0631\u0629',
      '\u0627\u0644\u0648\u0642\u062a',
    ];

    final rows = invoices.map((inv) {
      return [
        _fmtNum(inv.total),
        (inv.customerName ?? '-'),
        inv.paymentMethod == 'cash'
            ? '\u0646\u0642\u062f'
            : '\u0622\u062c\u0644',
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

  static String _fmtNum(double v) {
    if (v == v.roundToDouble()) {
      final s = v.toInt().toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return v.toStringAsFixed(2);
  }

  static Future<String> savePdfToDisk(
      Uint8List bytes, String invoiceNumber) async {
    final dir = Directory(r'D:\albaraka\data\receipts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final safeName = invoiceNumber.replaceAll('/', '_').replaceAll(':', '_');
    final fileName = safeName + '.pdf';
    final filePath = p.join(dir.path, fileName);
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }

  static Future<void> previewPdf(
      Uint8List bytes, String invoiceNumber) async {
    // v7.4/12: preview = save + open with viewer
    final dir = Directory(r'D:\albaraka\data\receipts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final safeName = invoiceNumber.replaceAll(
        RegExp(r'[\\/:*?"<>|]'), '_');
    final file = File(p.join(dir.path, '$safeName.pdf'));
    await file.writeAsBytes(bytes);
    await Process.run('cmd', ['/c', 'start', '', file.path]);
  }

  static Future<void> printPdf(
      Uint8List bytes, String invoiceNumber) async {
    await Printing.layoutPdf(
      onLayout: (_) async => bytes,
      name: 'فاتورة ' + invoiceNumber,
    );
  }
}
