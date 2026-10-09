import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Reusable PDF styling and component builders for MM spinning calculator reports
class PdfReportHelpers {
  static final navyColor = PdfColor.fromHex('0F172A');
  static final royalBlue = PdfColor.fromHex('1D4ED8');
  static final emerald = PdfColor.fromHex('10B981');
  static final lightBg = PdfColor.fromHex('F8FAFC');
  static const borderGrey = PdfColors.grey300;

  // Built-in PDF fonts cannot render these engineering punctuation glyphs.
  static String printableText(String text) => text
      .replaceAll('–', '-')
      .replaceAll('—', '-')
      .replaceAll('−', '-')
      .replaceAll('→', '->')
      .replaceAll('≤', '<=')
      .replaceAll('≥', '>=')
      .replaceAll('•', '-');

  static pw.Widget sectionTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 10, bottom: 6),
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue700, width: 1.5),
        ),
      ),
      child: pw.Text(
        printableText(title),
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: navyColor,
        ),
      ),
    );
  }

  static pw.Widget keyValGrid(Map<String, String> items) {
    final entries = items.entries.toList();
    final rows = <pw.TableRow>[];

    for (int i = 0; i < entries.length; i += 2) {
      final e1 = entries[i];
      final e2 = (i + 1 < entries.length) ? entries[i + 1] : null;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: (i ~/ 2) % 2 == 0 ? lightBg : PdfColors.white,
          ),
          children: [
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: pw.Text(printableText('${e1.key}:'),
                  style: const pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800)),
            ),
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: pw.Text(printableText(e1.value),
                  style: pw.TextStyle(fontSize: 9, color: navyColor)),
            ),
            if (e2 != null) ...[
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: pw.Text(printableText('${e2.key}:'),
                    style: const pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800)),
              ),
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: pw.Text(printableText(e2.value),
                    style: pw.TextStyle(fontSize: 9, color: navyColor)),
              ),
            ] else ...[
              pw.Container(),
              pw.Container(),
            ],
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: borderGrey, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(3),
      },
      children: rows,
    );
  }

  static pw.Widget summaryCard(String label, String value,
      {bool highlight = false}) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(3),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: pw.BoxDecoration(
        color: highlight ? PdfColor.fromHex('ECFDF5') : lightBg,
        border: pw.Border.all(
            color: highlight ? emerald : borderGrey,
            width: highlight ? 1.5 : 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            printableText(label.toUpperCase()),
            style: const pw.TextStyle(
                fontSize: 7.5,
                color: PdfColors.grey700,
                fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            printableText(value),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: highlight ? emerald : navyColor,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget dataTable({
    required List<String> headers,
    required List<List<String>> rows,
    List<double>? flexWidths,
  }) {
    Map<int, pw.TableColumnWidth> columnWidths = {};
    if (flexWidths != null) {
      for (int i = 0; i < flexWidths.length; i++) {
        columnWidths[i] = pw.FlexColumnWidth(flexWidths[i]);
      }
    }

    return pw.Table(
      border: pw.TableBorder.all(color: borderGrey, width: 0.5),
      columnWidths: columnWidths.isNotEmpty ? columnWidths : null,
      children: [
        // Header Row
        pw.TableRow(
          repeat: true,
          decoration: pw.BoxDecoration(color: navyColor),
          children: headers.map((h) {
            return pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: pw.Text(
                printableText(h),
                style: const pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        // Data Rows
        ...rows.asMap().entries.map((entry) {
          final idx = entry.key;
          final row = entry.value;
          final isEven = idx % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : lightBg,
            ),
            children: row.map((cell) {
              return pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: pw.Text(
                  printableText(cell),
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey900,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
