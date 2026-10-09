import 'package:flutter/material.dart';
import 'package:spin_logic/app/theme.dart';
import 'package:spin_logic/core/calc/count_conversion.dart';
import 'package:spin_logic/ui/widgets/input_card.dart';
import 'package:spin_logic/ui/widgets/page_scaffold.dart';
import 'package:spin_logic/ui/widgets/result_tile.dart';
import 'package:spin_logic/ui/widgets/styled_dropdown.dart';
import 'package:spin_logic/ui/widgets/styled_text_field.dart';

class CountConversionScreen extends StatefulWidget {
  const CountConversionScreen({super.key});

  @override
  State<CountConversionScreen> createState() => _CountConversionScreenState();
}

class _CountConversionScreenState extends State<CountConversionScreen> {
  // Card 1 state
  String _card1Input = '';
  String _card1Unit = CountConversion.ne;
  String? _card1Error;
  Map<String, double> _card1Results = {};

  // Card 2 state
  String _card2FindMode = 'Count/linear density from length and weight';
  String? _card2SampleLength;
  String _card2LengthInput = '';
  String _card2LengthUnit = 'yd';
  String _card2WeightInput = '';
  String _card2WeightUnit = 'g';
  String? _card2Error;
  Map<String, double> _card2Results = {};

  // Controllers for Card 2 to update text when sample length selected
  final TextEditingController _lengthController = TextEditingController();

  final List<String> _countUnits = [
    CountConversion.ne,
    CountConversion.nm,
    CountConversion.tex,
    CountConversion.denier,
    CountConversion.dtex,
    CountConversion.ktex,
    CountConversion.worsted,
    CountConversion.linen,
    CountConversion.woollen,
    CountConversion.grainsPerYd,
  ];

  @override
  void dispose() {
    _lengthController.dispose();
    super.dispose();
  }

  void _calculateCard1() {
    setState(() {
      _card1Error = null;
      _card1Results = {};

      if (_card1Input.isEmpty) return;

      final val = double.tryParse(_card1Input);
      if (val == null || val <= 0) {
        _card1Error = "Enter a valid positive number.";
        return;
      }

      _card1Results = CountConversion.convert(val, _card1Unit);
    });
  }

  void _calculateCard2() {
    setState(() {
      _card2Error = null;
      _card2Results = {};

      if (_card2LengthInput.isEmpty || _card2WeightInput.isEmpty) return;

      final lengthVal = double.tryParse(_card2LengthInput);
      final weightVal = double.tryParse(_card2WeightInput);

      if (lengthVal == null || lengthVal <= 0) {
        _card2Error = "Enter a length greater than zero.";
        return;
      }

      if (weightVal == null || weightVal < 0) {
        return;
      }

      double lengthMeters = lengthVal;
      switch (_card2LengthUnit) {
        case 'yd':
          lengthMeters *= 0.9144;
          break;
        case 'cm':
          lengthMeters *= 0.01;
          break;
        case 'in':
          lengthMeters *= 0.0254;
          break;
        case 'ft':
          lengthMeters *= 0.3048;
          break;
      }

      double weightGrams = weightVal;
      switch (_card2WeightUnit) {
        case 'mg':
          weightGrams *= 0.001;
          break;
        case 'kg':
          weightGrams *= 1000;
          break;
        case 'grain':
          weightGrams *= 0.06479891;
          break;
        case 'oz':
          weightGrams *= 28.3495;
          break;
        case 'lb':
          weightGrams *= 453.592;
          break;
      }

      final tex = CountConversion.texFromLengthWeight(
        lengthMeters: lengthMeters,
        weightGrams: weightGrams,
      );

      _card2Results = CountConversion.convertFromTex(tex);
    });
  }

  void _onSampleLengthSelected(String? value) {
    if (value == null) return;
    setState(() {
      _card2SampleLength = value;
      switch (value) {
        case 'Lea (120 yd)':
          _card2LengthUnit = 'yd';
          _lengthController.text = '120';
          break;
        case 'Hank (840 yd)':
          _card2LengthUnit = 'yd';
          _lengthController.text = '840';
          break;
        case '100 m':
          _card2LengthUnit = 'm';
          _lengthController.text = '100';
          break;
        case '10 m':
          _card2LengthUnit = 'm';
          _lengthController.text = '10';
          break;
        case '1 m':
          _card2LengthUnit = 'm';
          _lengthController.text = '1';
          break;
        case '1 yd':
          _card2LengthUnit = 'yd';
          _lengthController.text = '1';
          break;
      }
      _card2LengthInput = _lengthController.text;
      _calculateCard2();
    });
  }

  Widget _buildResultTiles(Map<String, double> results) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: _countUnits.map((unit) {
        final val = results[unit];
        String? displayValue;
        if (val != null) {
          displayValue = val.toStringAsFixed(2);
        }
        return SizedBox(
          width: 150,
          child: ResultTile(
            label: unit,
            value: displayValue,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Count Conversion',
      subtitle: 'Convert between different yarn count systems',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1
          InputCard(
            title: 'Count Converter',
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
                          _card1Input = val;
                          _calculateCard1();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: StyledDropdown<String>(
                        label: 'From Unit',
                        value: _card1Unit,
                        items: _countUnits.map((u) {
                          return DropdownMenuItem(value: u, child: Text(u));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _card1Unit = val;
                              _calculateCard1();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_card1Error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _card1Error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                _buildResultTiles(_card1Results),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Card 2
          InputCard(
            title: 'Linear Density Calculator',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledDropdown<String>(
                  label: 'What do you want to find?',
                  value: _card2FindMode,
                  items: [
                    'Count/linear density from length and weight',
                    'Weight from count and length'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _card2FindMode = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                StyledDropdown<String>(
                  label: 'Common sample length',
                  value: _card2SampleLength,
                  items: [
                    'Lea (120 yd)',
                    'Hank (840 yd)',
                    '100 m',
                    '10 m',
                    '1 m',
                    '1 yd'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: _onSampleLengthSelected,
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Length',
                            style: TextStyle(
                              color: SpinColors.textGrey,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _lengthController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) {
                              _card2LengthInput = val;
                              _calculateCard2();
                            },
                            decoration: const InputDecoration(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: StyledDropdown<String>(
                        label: 'Unit',
                        value: _card2LengthUnit,
                        items: ['m', 'yd', 'cm', 'in', 'ft']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _card2LengthUnit = val;
                              _calculateCard2();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: StyledTextField(
                        label: 'Weight',
                        isNumber: true,
                        onChanged: (val) {
                          _card2WeightInput = val;
                          _calculateCard2();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: StyledDropdown<String>(
                        label: 'Unit',
                        value: _card2WeightUnit,
                        items: ['g', 'mg', 'kg', 'grain', 'oz', 'lb']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _card2WeightUnit = val;
                              _calculateCard2();
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                if (_card2Error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _card2Error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 24),
                _buildResultTiles(_card2Results),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
