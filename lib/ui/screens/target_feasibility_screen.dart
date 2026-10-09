import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../widgets/pdf_report_helpers.dart';
import '../widgets/responsive_layout.dart';

class TargetFeasibilityScreen extends StatefulWidget {
  const TargetFeasibilityScreen({super.key});

  @override
  State<TargetFeasibilityScreen> createState() =>
      _TargetFeasibilityScreenState();
}

class _TargetFeasibilityScreenState extends State<TargetFeasibilityScreen> {
  double _targetNe = 40.0;
  String _spinningRoute = 'Combed ring';
  double _fibreLength = 29.5;
  double _lengthUniformity = 82.5;
  double _micronaire = 4.1;
  double _fibreStrength = 30.5;
  double _shortFibreContent = 7.5;
  double _maturityIndex = 0.86;
  double _tm = 3.65;

  double get _yarnTex => _targetNe > 0 ? 590.5 / _targetNe : 0.0;
  double get _reqFibreTex => _micronaire / 25.38;

  double get _fibresPerSection =>
      _reqFibreTex > 0 ? _yarnTex / _reqFibreTex : 0.0;
  double get _targetTpi => _tm * sqrt(_targetNe);

  String get _spinnabilityAssessment {
    if (_fibresPerSection < 70) {
      return "High risk / marginal spinnability (too few fibres in cross-section)";
    } else if (_fibresPerSection < 85) {
      return "Feasible with combed/compact route, sensitive to machine settings";
    } else {
      return "Spinnable with comfortable safety margin";
    }
  }

  String get _practicalCountRange {
    double minNe = 28.0;
    double maxNe = (_reqFibreTex > 0 ? (590.5 / (70 * _reqFibreTex)) : 50.0);
    return "${minNe.toInt()} – ${maxNe.toInt()} Ne";
  }

  List<String> get _limitingFactors {
    List<String> factors = [];
    if (_micronaire > 4.5) {
      factors.add("Micronaire is high, reducing fibres per cross section.");
    }
    if (_fibreStrength < 28) factors.add("Fibre strength is low.");
    if (_shortFibreContent > 10) {
      factors.add("Short fibre content is high, might increase waste.");
    }
    if (_lengthUniformity < 80) {
      factors.add("Length uniformity is low, affecting yarn evenness.");
    }
    if (factors.isEmpty) {
      factors
          .add("No significant limiting factors based on typical thresholds.");
    }
    return factors;
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final widgets = <pw.Widget>[];

    widgets.add(pw.Text(
      'Engineering screening only: this does not guarantee spinnability. Final suitability depends on the complete HVI profile, blend variation, preparation quality, machine condition, twist, drafting, humidity and actual mill trials.',
      style: const pw.TextStyle(fontSize: 9, color: PdfColors.orange800),
    ));

    // Inputs
    widgets
        .add(PdfReportHelpers.sectionTitle('1. Target Yarn & Fiber Profile'));
    widgets.add(
      PdfReportHelpers.keyValGrid({
        'Target Yarn Count': '${_targetNe.toStringAsFixed(1)} Ne',
        'Spinning Route': _spinningRoute,
        'Fiber Length': '${_fibreLength.toStringAsFixed(1)} mm',
        'Length Uniformity': '${_lengthUniformity.toStringAsFixed(1)}%',
        'Micronaire': '${_micronaire.toStringAsFixed(2)} µg/in',
        'Fiber Strength': '${_fibreStrength.toStringAsFixed(1)} g/tex',
        'Short Fiber Content': '${_shortFibreContent.toStringAsFixed(1)}%',
        'Maturity Index': _maturityIndex.toStringAsFixed(2),
        'Twist Multiplier (TM)': _tm.toStringAsFixed(2),
      }),
    );
    widgets.add(pw.SizedBox(height: 12));

    // Results
    widgets.add(PdfReportHelpers.sectionTitle(
        '2. Spinnability & Engineering Assessment'));
    widgets.add(
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PdfReportHelpers.summaryCard(
              'Practical Count Range', _practicalCountRange,
              highlight: true),
          PdfReportHelpers.summaryCard(
              'Fibres / Cross-Section', _fibresPerSection.toStringAsFixed(1),
              highlight: _fibresPerSection >= 70),
          PdfReportHelpers.summaryCard(
              'Target TPI', _targetTpi.toStringAsFixed(2)),
          PdfReportHelpers.summaryCard('Yarn Tex', _yarnTex.toStringAsFixed(2)),
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 10));

    // Assessment Banner
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _fibresPerSection >= 70
              ? PdfColor.fromHex('F0FDF4')
              : PdfColor.fromHex('FEF2F2'),
          border: pw.Border.all(
            color: _fibresPerSection >= 70
                ? PdfColor.fromHex('10B981')
                : PdfColor.fromHex('EF4444'),
          ),
          borderRadius: pw.BorderRadius.circular(4),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Feasibility Recommendation: $_spinnabilityAssessment',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _fibresPerSection >= 70
                    ? PdfColor.fromHex('065F46')
                    : PdfColor.fromHex('991B1B'),
              ),
            ),
          ],
        ),
      ),
    );
    widgets.add(pw.SizedBox(height: 12));

    // Limiting factors
    widgets.add(PdfReportHelpers.sectionTitle(
        '3. Limiting Factors & Mill Trial Directives'));
    for (var f in _limitingFactors) {
      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('- ',
                  style: const pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                      color: PdfColors.blue800)),
              pw.Expanded(
                child: pw.Text(f,
                    style: const pw.TextStyle(
                        fontSize: 9.5, color: PdfColors.grey900)),
              ),
            ],
          ),
        ),
      );
    }

    widgets.add(PdfReportHelpers.sectionTitle('4. Recommended Trial'));
    for (final recommendation in [
      'Trial with $_spinningRoute route recommended.',
      'Monitor nep levels closely.',
      'Ensure optimal twist settings to avoid breakage.',
    ]) {
      widgets.add(pw.Text(
        '- $recommendation',
        style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900),
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Target count feasibility',
      subtitle:
          'Screen a cotton lot against a target Ne count and get a practical trial recommendation.',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border:
                  const Border(left: BorderSide(color: Colors.amber, width: 4)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Engineering screening only: this does not guarantee spinnability. Final suitability depends on the complete HVI profile, blend variation, preparation quality, machine condition, twist, drafting, humidity and actual mill trials.',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: 'Inputs',
            child: ResponsiveResults(
              children: [
                SizedBox(
                  width: 150,
                  child: StyledTextField(
                    label: 'Target count (Ne)',
                    initialValue: _targetNe.toString(),
                    onChanged: (val) =>
                        setState(() => _targetNe = double.tryParse(val) ?? 0.0),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: StyledDropdown<String>(
                    label: 'Spinning route',
                    value: _spinningRoute,
                    items: const [
                      DropdownMenuItem(
                          value: 'Carded ring', child: Text('Carded ring')),
                      DropdownMenuItem(
                          value: 'Combed ring', child: Text('Combed ring')),
                      DropdownMenuItem(
                          value: 'Combed compact',
                          child: Text('Combed compact')),
                    ],
                    onChanged: (val) =>
                        setState(() => _spinningRoute = val ?? 'Combed ring'),
                  ),
                ),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Fibre length (mm)',
                        initialValue: _fibreLength.toString(),
                        onChanged: (val) => setState(
                            () => _fibreLength = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Length uniformity (%)',
                        initialValue: _lengthUniformity.toString(),
                        onChanged: (val) => setState(() =>
                            _lengthUniformity = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Micronaire (µg/in)',
                        initialValue: _micronaire.toString(),
                        onChanged: (val) => setState(
                            () => _micronaire = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Fibre strength (g/tex)',
                        initialValue: _fibreStrength.toString(),
                        onChanged: (val) => setState(() =>
                            _fibreStrength = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Short fibre (%)',
                        initialValue: _shortFibreContent.toString(),
                        onChanged: (val) => setState(() =>
                            _shortFibreContent = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Maturity index',
                        initialValue: _maturityIndex.toString(),
                        onChanged: (val) => setState(() =>
                            _maturityIndex = double.tryParse(val) ?? 0.0))),
                SizedBox(
                    width: 150,
                    child: StyledTextField(
                        label: 'Twist multiplier (TM)',
                        initialValue: _tm.toString(),
                        onChanged: (val) =>
                            setState(() => _tm = double.tryParse(val) ?? 0.0))),
              ],
            ),
          ),
          InputCard(
            title: 'Results',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultTile(
                    label: 'Target count assessment',
                    value: _spinnabilityAssessment,
                    highlight: true),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    ResultTile(
                        label: 'Practical count range',
                        value: _practicalCountRange),
                    ResultTile(
                        label: 'Est. fibres / cross-section',
                        value: _fibresPerSection.toStringAsFixed(0)),
                    ResultTile(
                        label: 'Target TPI',
                        value: _targetTpi.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          InputCard(
            title: 'Recommended trial',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Trial with $_spinningRoute route recommended.'),
                const Text('• Monitor nep levels closely.'),
                const Text(
                    '• Ensure optimal twist settings to avoid breakage.'),
              ],
            ),
          ),
          InputCard(
            title: 'Limiting factors (Review these first)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _limitingFactors.map((f) => Text('• $f')).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
