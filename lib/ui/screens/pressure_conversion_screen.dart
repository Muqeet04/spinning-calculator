import 'package:flutter/material.dart';
import 'package:spin_logic/core/calc/pressure_conversion.dart';
import 'package:spin_logic/ui/widgets/input_card.dart';
import 'package:spin_logic/ui/widgets/page_scaffold.dart';
import 'package:spin_logic/ui/widgets/result_tile.dart';
import 'package:spin_logic/ui/widgets/styled_dropdown.dart';
import 'package:spin_logic/ui/widgets/styled_text_field.dart';

class PressureConversionScreen extends StatefulWidget {
  const PressureConversionScreen({super.key});

  @override
  State<PressureConversionScreen> createState() => _PressureConversionScreenState();
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Pressure Conversion',
      subtitle: 'Convert between different pressure units',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: 'Pressure Converter',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
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
