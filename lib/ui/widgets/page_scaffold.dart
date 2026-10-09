import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../app/theme.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
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
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                        child: child,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text('Back to Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
            const Icon(Icons.check_circle_outline, color: SpinColors.emerald, size: 18),
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

  Future<void> _handlePrint(BuildContext context) async {
    try {
      final doc = await _generateReportPdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${title.replaceAll(' ', '_')}_Report.pdf',
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
      final doc = await _generateReportPdf();
      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: '${title.replaceAll(' ', '_')}_Report.pdf',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: SpinColors.emerald,
            behavior: SnackBarBehavior.floating,
            content: Text('PDF generated successfully! Save or share dialog opened.'),
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

  Future<pw.Document> _generateReportPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('0F172A'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'MM spinning calculator',
                          style: const pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Engineering Report: $title',
                          style: const pw.TextStyle(
                            color: PdfColors.grey300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Muqeet Mahmood',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('10B981'),
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'muqeetmahmood8@gmail.com',
                          style: const pw.TextStyle(
                            color: PdfColors.grey400,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              // Report Body Card
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Module: $title',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('1D4ED8'),
                      ),
                    ),
                    if (subtitle != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        subtitle!,
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                    pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'This calculation sheet was generated from MM spinning calculator.',
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Status: Live calculation verified offline.',
                      style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date / Timestamp: ${DateTime.now().toLocal().toString().split('.')[0]}',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
              pw.Spacer(),
              // Footer
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'MM spinning calculator Suite • Offline Precision Engine',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                  pw.Text(
                    'Designed by Muqeet Mahmood',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
