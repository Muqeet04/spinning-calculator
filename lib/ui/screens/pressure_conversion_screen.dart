import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:spin_logic/core/calc/pressure_conversion.dart';
import 'package:spin_logic/ui/widgets/input_card.dart';
import 'package:spin_logic/ui/widgets/page_scaffold.dart';
import 'package:spin_logic/ui/widgets/pdf_report_helpers.dart';
import 'package:spin_logic/ui/widgets/result_tile.dart';
import 'package:spin_logic/ui/widgets/styled_dropdown.dart';
import 'package:spin_logic/ui/widgets/styled_text_field.dart';
import '../widgets/responsive_layout.dart';

class PressureConversionScreen extends StatefulWidget {
  const PressureConversionScreen({super.key});

  @override
  State<PressureConversionScreen> createState() =>
      _PressureConversionScreenState();
}

class _PressureConversionScreenState extends State<PressureConversionScreen> {
  String _input = '';
  String _unit = PressureConversion.bar;
  String? _error;
  Map<String, double> _results = {};

  final List<String> _units = [
    PressureConversion.bar,
    PressureConversion.psi,
    PressureConversion.kgCm2,
    PressureConversion.kpa,
    PressureConversion.mmhg,
    PressureConversion.atm,
    PressureConversion.mbar,
  ];

  void _calculate() {
    setState(() {
      _error = null;
      _results = {};

      if (_input.isEmpty) return;

      final val = double.tryParse(_input);
      if (val == null || val <= 0) {
        _error = "Enter a valid positive number.";
        return;
      }

      _results = PressureConversion.convert(val, _unit);
    });
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final widgets = <pw.Widget>[
      PdfReportHelpers.sectionTitle('1. Input Parameters'),
      PdfReportHelpers.keyValGrid({
        'Pressure value': _input.trim().isEmpty ? 'Not entered' : _input,
        'Input unit': _unit,
      }),
      PdfReportHelpers.sectionTitle('2. Pressure Conversions'),
    ];

    final value = double.tryParse(_input);
    if (value == null || !value.isFinite || value <= 0) {
      widgets.add(pw.Text(
        'Results unavailable: enter a valid positive pressure value.',
        style: const pw.TextStyle(color: PdfColors.red, fontSize: 10),
      ));
      return widgets;
    }

    final results = PressureConversion.convert(value, _unit);
    if (results.values.any((result) => !result.isFinite)) {
      throw StateError('The pressure value is too large to convert.');
    }
    widgets.add(PdfReportHelpers.dataTable(
      headers: ['Pressure unit', 'Converted value'],
      rows: _units
          .map((unit) => [
                unit,
                results[unit]!.toString(),
              ])
          .toList(),
    ));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Pressure Conversion',
      subtitle: 'Convert between different pressure units',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: 'Pressure Converter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveRow(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: StyledTextField(
                        label: 'Value',
                        isNumber: true,
                        onChanged: (val) {
                          _input = val;
                          _calculate();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: StyledDropdown<String>(
                        label: 'Unit',
                        value: _unit,
                        items: _units.map((u) {
                          return DropdownMenuItem(value: u, child: Text(u));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _unit = val;
                              _calculate();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                ResponsiveResults(
                  children: _units.map((unit) {
                    final val = _results[unit];
                    String? displayValue;
                    if (val != null) {
                      displayValue = val.toString();
                    }
                    return SizedBox(
                      width: 150,
                      child: ResultTile(
                        label: unit,
                        value: displayValue,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
