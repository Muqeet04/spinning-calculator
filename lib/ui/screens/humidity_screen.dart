import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/calc/humidity.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../widgets/pdf_report_helpers.dart';
import '../widgets/responsive_layout.dart';

class HumidityScreen extends StatefulWidget {
  const HumidityScreen({super.key});

  @override
  State<HumidityScreen> createState() => _HumidityScreenState();
}

class _HumidityScreenState extends State<HumidityScreen> {
  String _dryBulbF = '';
  String _wetBulbF = '';
  String _pressure = '1013.25';
  String _psychrometerType = 'Aspirated / sling (A=0.000662)';

  HumidityResult? _result;
  String? _errorMsg;

  void _calculate() {
    setState(() {
      _result = null;
      _errorMsg = null;

      final dryF = double.tryParse(_dryBulbF);
      final wetF = double.tryParse(_wetBulbF);
      final p = double.tryParse(_pressure) ?? 1013.25;

      if (dryF == null || wetF == null) {
        return;
      }

      if (wetF > dryF) {
        _errorMsg = 'Wet bulb temperature must be ≤ dry bulb temperature.';
        return;
      }

      _result = HumidityCalculator.calculate(
        dryBulbF: dryF,
        wetBulbF: wetF,
        pressure: p == 0 ? 1013.25 : p,
        isAspirated: _psychrometerType == 'Aspirated / sling (A=0.000662)',
      );
    });
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final isAspirated = _psychrometerType == 'Aspirated / sling (A=0.000662)';
    final enteredPressure = double.tryParse(_pressure);
    final effectivePressure = enteredPressure == null || enteredPressure == 0
        ? 1013.25
        : enteredPressure;
    final widgets = <pw.Widget>[
      PdfReportHelpers.sectionTitle('1. Input Parameters'),
      PdfReportHelpers.keyValGrid({
        'Dry bulb temperature (°F)':
            _dryBulbF.trim().isEmpty ? 'Not entered' : _dryBulbF,
        'Wet bulb temperature (°F)':
            _wetBulbF.trim().isEmpty ? 'Not entered' : _wetBulbF,
        'Atmospheric pressure entered (hPa)':
            _pressure.trim().isEmpty ? 'Not entered' : _pressure,
        'Atmospheric pressure used (hPa)': effectivePressure.toString(),
        'Psychrometer type': _psychrometerType,
        'Psychrometer constant A': isAspirated ? '0.000662' : '0.0008',
      }),
    ];
    if (enteredPressure == null || enteredPressure == 0) {
      widgets.add(pw.Text(
        'Atmospheric pressure defaults to 1013.25 hPa when the entry is '
        'empty, invalid, or zero.',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
      ));
    }
    widgets.add(PdfReportHelpers.sectionTitle('2. Computed Humidity Results'));
    final targetWidgets = <pw.Widget>[
      PdfReportHelpers.sectionTitle('3. Typical Relative Humidity Targets'),
      PdfReportHelpers.keyValGrid({
        'Blow room / Carding': '55–60%',
        'Ring spinning': '45–55%',
        'Winding': '60–70%',
      }),
    ];

    final dryF = double.tryParse(_dryBulbF);
    final wetF = double.tryParse(_wetBulbF);
    String? error;
    if (dryF == null || wetF == null || !dryF.isFinite || !wetF.isFinite) {
      error = 'Enter valid dry and wet bulb temperatures.';
    } else if (wetF > dryF) {
      error = 'Wet bulb temperature must be less than or equal to dry bulb '
          'temperature.';
    } else if (!effectivePressure.isFinite || effectivePressure <= 0) {
      error = 'Enter a valid positive atmospheric pressure.';
    }
    if (error != null) {
      widgets.add(pw.Text(
        'Results unavailable: $error',
        style: const pw.TextStyle(color: PdfColors.red, fontSize: 10),
      ));
      widgets.addAll(targetWidgets);
      return widgets;
    }

    final result = HumidityCalculator.calculate(
      dryBulbF: dryF!,
      wetBulbF: wetF!,
      pressure: effectivePressure,
      isAspirated: isAspirated,
    );
    if ([
      result.dryBulbC,
      result.wetBulbC,
      result.relativeHumidity,
      result.saturationPressureDry,
      result.saturationPressureWet,
      result.actualVaporPressure,
    ].any((value) => !value.isFinite)) {
      widgets.add(pw.Text(
        'Results unavailable: the temperature values are outside the '
        'calculation range. Enter valid psychrometer readings.',
        style: const pw.TextStyle(color: PdfColors.red, fontSize: 10),
      ));
      widgets.addAll(targetWidgets);
      return widgets;
    }
    widgets.addAll([
      PdfReportHelpers.keyValGrid({
        'Dry bulb temperature (°C)': result.dryBulbC.toStringAsFixed(2),
        'Wet bulb temperature (°C)': result.wetBulbC.toStringAsFixed(2),
        'Relative humidity (%)': result.relativeHumidity.toStringAsFixed(2),
        'Dry bulb saturation pressure (hPa)':
            result.saturationPressureDry.toStringAsFixed(4),
        'Wet bulb saturation pressure (hPa)':
            result.saturationPressureWet.toStringAsFixed(4),
        'Actual vapor pressure (hPa)':
            result.actualVaporPressure.toStringAsFixed(4),
      }),
      ...targetWidgets,
    ]);
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Relative Humidity Calculator',
      subtitle: 'Dry & wet bulb °F to °C, RH% from a psychrometer reading',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            breakpoint: 900,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: InputCard(
                  title: 'Inputs',
                  child: Column(
                    children: [
                      StyledTextField(
                        label: 'Dry bulb temperature (°F)',
                        isNumber: true,
                        onChanged: (val) {
                          _dryBulbF = val;
                          _calculate();
                        },
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Wet bulb temperature (°F)',
                        isNumber: true,
                        errorText: _errorMsg,
                        onChanged: (val) {
                          _wetBulbF = val;
                          _calculate();
                        },
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Atmospheric pressure (hPa)',
                        initialValue: _pressure,
                        isNumber: true,
                        onChanged: (val) {
                          _pressure = val;
                          _calculate();
                        },
                      ),
                      const SizedBox(height: 16),
                      StyledDropdown<String>(
                        label: 'Psychrometer type',
                        value: _psychrometerType,
                        items: const [
                          DropdownMenuItem(
                              value: 'Aspirated / sling (A=0.000662)',
                              child: Text('Aspirated / sling (A=0.000662)')),
                          DropdownMenuItem(
                              value: 'Natural draft (A=0.0008)',
                              child: Text('Natural draft (A=0.0008)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _psychrometerType = val;
                            _calculate();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    InputCard(
                      title: 'Results',
                      child: ResponsiveResults(
                        children: [
                          ResultTile(
                            label: 'Dry bulb °C',
                            value: _result?.dryBulbC.toStringAsFixed(2),
                          ),
                          ResultTile(
                            label: 'Wet bulb °C',
                            value: _result?.wetBulbC.toStringAsFixed(2),
                          ),
                          ResultTile(
                            label: 'RH %',
                            value: _result?.relativeHumidity.toStringAsFixed(2),
                            highlight: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const InputCard(
                      title: 'Typical Targets',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• Blow room / Carding: 55–60%',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('• Ring spinning: 45–55%',
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 8),
                          Text('• Winding: 60–70%',
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
