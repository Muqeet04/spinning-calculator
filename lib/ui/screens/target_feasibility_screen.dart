import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';

class TargetFeasibilityScreen extends StatefulWidget {
  const TargetFeasibilityScreen({super.key});

  @override
  State<TargetFeasibilityScreen> createState() => _TargetFeasibilityScreenState();
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
  
  double get _fibresPerSection => _reqFibreTex > 0 ? _yarnTex / _reqFibreTex : 0.0;
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
    if (_micronaire > 4.5) factors.add("Micronaire is high, reducing fibres per cross section.");
    if (_fibreStrength < 28) factors.add("Fibre strength is low.");
    if (_shortFibreContent > 10) factors.add("Short fibre content is high, might increase waste.");
    if (_lengthUniformity < 80) factors.add("Length uniformity is low, affecting yarn evenness.");
    if (factors.isEmpty) factors.add("No significant limiting factors based on typical thresholds.");
    return factors;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Target count feasibility',
      subtitle: 'Screen a cotton lot against a target Ne count and get a practical trial recommendation.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              border: const Border(left: BorderSide(color: Colors.amber, width: 4)),
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
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 150,
                  child: StyledTextField(
                    label: 'Target count (Ne)',
                    initialValue: _targetNe.toString(),
                    onChanged: (val) => setState(() => _targetNe = double.tryParse(val) ?? 0.0),
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: StyledDropdown<String>(
                    label: 'Spinning route',
                    value: _spinningRoute,
                    items: const [
                      DropdownMenuItem(value: 'Carded ring', child: Text('Carded ring')),
                      DropdownMenuItem(value: 'Combed ring', child: Text('Combed ring')),
                      DropdownMenuItem(value: 'Combed compact', child: Text('Combed compact')),
                    ],
                    onChanged: (val) => setState(() => _spinningRoute = val ?? 'Combed ring'),
                  ),
                ),
                SizedBox(width: 150, child: StyledTextField(label: 'Fibre length (mm)', initialValue: _fibreLength.toString(), onChanged: (val) => setState(() => _fibreLength = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Length uniformity (%)', initialValue: _lengthUniformity.toString(), onChanged: (val) => setState(() => _lengthUniformity = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Micronaire (µg/in)', initialValue: _micronaire.toString(), onChanged: (val) => setState(() => _micronaire = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Fibre strength (g/tex)', initialValue: _fibreStrength.toString(), onChanged: (val) => setState(() => _fibreStrength = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Short fibre (%)', initialValue: _shortFibreContent.toString(), onChanged: (val) => setState(() => _shortFibreContent = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Maturity index', initialValue: _maturityIndex.toString(), onChanged: (val) => setState(() => _maturityIndex = double.tryParse(val) ?? 0.0))),
                SizedBox(width: 150, child: StyledTextField(label: 'Twist multiplier (TM)', initialValue: _tm.toString(), onChanged: (val) => setState(() => _tm = double.tryParse(val) ?? 0.0))),
              ],
            ),
          ),
          InputCard(
            title: 'Results',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResultTile(label: 'Target count assessment', value: _spinnabilityAssessment, highlight: true),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ResultTile(label: 'Practical count range', value: _practicalCountRange),
                    ResultTile(label: 'Est. fibres / cross-section', value: _fibresPerSection.toStringAsFixed(0)),
                    ResultTile(label: 'Target TPI', value: _targetTpi.toStringAsFixed(2)),
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
                const Text('• Ensure optimal twist settings to avoid breakage.'),
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
