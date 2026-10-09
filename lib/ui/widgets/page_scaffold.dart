import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/theme.dart';
import 'pdf_report_helpers.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Future<List<pw.Widget>> Function(pw.Context)? onGeneratePdfReport;

  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.onGeneratePdfReport,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpinColors.pageBg,
      body: Stack(
        children: [
          // Subtle background decorative watermark
          const Positioned(
            right: -60,
            bottom: -60,
            child: Opacity(
              opacity: 0.02,
              child: Icon(
                Icons.hexagon_outlined,
                size: 340,
                color: SpinColors.royalBlue,
              ),
            ),
          ),
          // Content
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.sizeOf(context).width < 600
                                ? 16
                                : 24,
                            vertical: 20,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    if (size.width >= 800 * scale.clamp(1, 1.5) && size.height >= 500) {
      return _buildWideHeader(context);
    }
    final isHome = title == 'MM spinning calculator' || title == 'Spin Logic';
    return Material(
      color: SpinColors.royalNavy,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SpinColors.emerald, width: 2.5),
            ),
          ),
          child: Row(
            children: [
              if (!isHome)
                IconButton(
                  tooltip: 'Back to Menu',
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: 'Actions',
                style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (action) {
                  switch (action) {
                    case 'data':
                      _handleSaveData(context);
                    case 'print':
                      _handlePrint(context);
                    case 'pdf':
                      _handleSavePdf(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'data', child: Text('Save data')),
                  if (onGeneratePdfReport != null) ...[
                    const PopupMenuItem(value: 'print', child: Text('Print')),
                    const PopupMenuItem(value: 'pdf', child: Text('Save PDF')),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWideHeader(BuildContext context) {
    final isHome = title == 'MM spinning calculator' || title == 'Spin Logic';
    return Container(
      decoration: const BoxDecoration(
        color: SpinColors.royalNavy,
        border: Border(
          bottom: BorderSide(color: SpinColors.emerald, width: 2.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isHome)
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Back to Menu',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  children: [
                    _buildActionButton(
                      label: 'Save data',
                      bg: SpinColors.emerald,
                      text: Colors.white,
                      icon: Icons.save_outlined,
                      onTap: () => _handleSaveData(context),
                    ),
                    if (onGeneratePdfReport != null) ...[
                      const SizedBox(width: 8),
                      _buildActionButton(
                        label: 'Print',
                        bg: Colors.transparent,
                        text: Colors.white,
                        icon: Icons.print_outlined,
                        border: Colors.white.withValues(alpha: 0.35),
                        onTap: () => _handlePrint(context),
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        label: 'Save PDF',
                        bg: SpinColors.royalBlue,
                        text: Colors.white,
                        icon: Icons.picture_as_pdf_outlined,
                        onTap: () => _handleSavePdf(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            if (isHome) ...[
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 110,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.hexagon_outlined,
                        size: 70,
                        color: SpinColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 38,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.hexagon_outlined,
                      size: 28,
                      color: SpinColors.emerald,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color bg,
    required Color text,
    required VoidCallback onTap,
    IconData? icon,
    Color? border,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: border != null ? Border.all(color: border) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: text),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpinColors.royalNavy,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: SpinColors.emerald,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Data saved successfully in local storage for "$title".',
                style: const TextStyle(fontSize: 13, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String get _reportFilename =>
      '${title.replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')}_Report.pdf';

  Future<void> _handlePrint(BuildContext context) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = await generateReportPdf(pageFormat: format);
          return doc.save();
        },
        name: _reportFilename,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SpinColors.errorRed,
            content: Text('Could not open print preview: $e'),
          ),
        );
      }
    }
  }

  Future<void> _handleSavePdf(BuildContext context) async {
    try {
      final doc = await generateReportPdf();
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: _reportFilename,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: SpinColors.emerald,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'PDF generated successfully! Save or share dialog opened.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SpinColors.errorRed,
            content: Text('Error generating PDF: $e'),
          ),
        );
      }
    }
  }

  /// Builds the same calculation report for printing and saving.
  Future<pw.Document> generateReportPdf({
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final reportBuilder = onGeneratePdfReport;
    if (reportBuilder == null) {
      throw StateError('No calculation report is available for "$title".');
    }
    final pdf = pw.Document(title: title, author: 'Muqeet Mahmood');

    final navyColor = PdfColor.fromHex('0F172A');
    final emeraldColor = PdfColor.fromHex('10B981');
    final blueColor = PdfColor.fromHex('1D4ED8');

    final dynamicContent = await reportBuilder(
      pw.Context(document: pdf.document),
    );
    if (dynamicContent.isEmpty) {
      throw StateError('The calculation report for "$title" is empty.');
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        maxPages: 100,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: navyColor,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MM spinning calculator',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        PdfReportHelpers.printableText(
                          'Engineering Report: $title',
                        ),
                        style: const pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Muqeet Mahmood',
                      style: pw.TextStyle(
                        color: emeraldColor,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'muqeetmahmood8@gmail.com',
                      style: const pw.TextStyle(
                        color: PdfColors.grey400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            padding: const pw.EdgeInsets.only(top: 6),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    'MM spinning calculator Suite - muqeetmahmood8@gmail.com',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Meta card
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColor.fromHex('F8FAFC'),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    PdfReportHelpers.printableText(title),
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      PdfReportHelpers.printableText(subtitle!),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Current inputs and results',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: emeraldColor,
                    ),
                  ),
                  pw.Text(
                    'Generated: ${DateTime.now().toLocal().toString().split('.')[0]}',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            ...dynamicContent,
          ];
        },
      ),
    );

    return pdf;
  }
}
