import 'package:flutter/material.dart';
import '../../core/calc/ring_doff.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';

class RingDoffScreen extends StatefulWidget {
  const RingDoffScreen({super.key});

  @override
  State<RingDoffScreen> createState() => _RingDoffScreenState();
}

class _RingDoffScreenState extends State<RingDoffScreen> {
  final _referenceTable = [
    {'count': 20.0, 'speed': 15500.0, 'tpi': 18.40, 'bobbin': 70.0, 'roving': 1800.0},
    {'count': 24.0, 'speed': 17500.0, 'tpi': 19.60, 'bobbin': 62.0, 'roving': 1700.0},
    {'count': 30.0, 'speed': 19500.0, 'tpi': 21.08, 'bobbin': 55.0, 'roving': 1600.0},
    {'count': 34.0, 'speed': 20500.0, 'tpi': 21.90, 'bobbin': 50.0, 'roving': 1550.0},
    {'count': 40.0, 'speed': 22712.0, 'tpi': 22.96, 'bobbin': 45.1, 'roving': 1500.0},
    {'count': 50.0, 'speed': 22000.0, 'tpi': 25.46, 'bobbin': 38.0, 'roving': 1400.0},
    {'count': 60.0, 'speed': 21000.0, 'tpi': 27.89, 'bobbin': 33.0, 'roving': 1300.0},
    {'count': 70.0, 'speed': 19500.0, 'tpi': 30.12, 'bobbin': 28.0, 'roving': 1200.0},
    {'count': 80.2, 'speed': 18000.0, 'tpi': 32.26, 'bobbin': 24.0, 'roving': 1100.0},
  ];

  String _calcMode = 'Auto from count';
  
  String _yarnCount = '40';
  String _spindleSpeed = '22712';
  String _tpi = '22.96';
  String _ringBobbinWeight = '45.1';
  String _rovingPackageWeight = '1500';
  String _ringCupDiameter = '38';
  String _frameSpindles = '1824';
  String _shiftLength = '8';

  final _speedCtrl = TextEditingController(text: '22712');
  final _tpiCtrl = TextEditingController(text: '22.96');
  final _bobbinCtrl = TextEditingController(text: '45.1');
  final _rovingCtrl = TextEditingController(text: '1500');
  
  RingDoffResult? _result;
  String? _warningMsg;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  void dispose() {
    _speedCtrl.dispose();
    _tpiCtrl.dispose();
    _bobbinCtrl.dispose();
    _rovingCtrl.dispose();
    super.dispose();
  }

  void _interpolate(double count) {
    _warningMsg = null;
    if (_referenceTable.isEmpty) return;

    if (count < _referenceTable.first['count']! || count > _referenceTable.last['count']!) {
      _warningMsg = "Count is outside the reference-sheet range (20–80.2 Ne). Values are extrapolated from the nearest reference segment.";
    }

    Map<String, double> p1 = _referenceTable.first;
    Map<String, double> p2 = _referenceTable.last;
    
    for (int i = 0; i < _referenceTable.length - 1; i++) {
      if (count >= _referenceTable[i]['count']! && count <= _referenceTable[i+1]['count']!) {
        p1 = _referenceTable[i];
        p2 = _referenceTable[i+1];
        break;
      }
    }

    if (count < _referenceTable.first['count']!) {
      p1 = _referenceTable[0];
      p2 = _referenceTable[1];
    } else if (count > _referenceTable.last['count']!) {
      p1 = _referenceTable[_referenceTable.length - 2];
      p2 = _referenceTable.last;
    }

    double ratio = (count - p1['count']!) / (p2['count']! - p1['count']!);
    
    double speed = p1['speed']! + ratio * (p2['speed']! - p1['speed']!);
    double tpi = p1['tpi']! + ratio * (p2['tpi']! - p1['tpi']!);
    double bobbin = p1['bobbin']! + ratio * (p2['bobbin']! - p1['bobbin']!);
    double roving = p1['roving']! + ratio * (p2['roving']! - p1['roving']!);

    _spindleSpeed = speed.toStringAsFixed(2);
    _tpi = tpi.toStringAsFixed(2);
    _ringBobbinWeight = bobbin.toStringAsFixed(2);
    _rovingPackageWeight = roving.toStringAsFixed(2);

    _speedCtrl.text = _spindleSpeed;
    _tpiCtrl.text = _tpi;
    _bobbinCtrl.text = _ringBobbinWeight;
    _rovingCtrl.text = _rovingPackageWeight;
  }

  void _calculate() {
    setState(() {
      _result = null;
      if (_calcMode == 'Auto from count') {
        final count = double.tryParse(_yarnCount);
        if (count != null) {
          _interpolate(count);
        } else {
          return;
        }
      } else {
        _warningMsg = null;
      }

      final c = double.tryParse(_yarnCount);
      final s = double.tryParse(_spindleSpeed);
      final t = double.tryParse(_tpi);
      final b = double.tryParse(_ringBobbinWeight);
      final r = double.tryParse(_rovingPackageWeight);
      final d = double.tryParse(_ringCupDiameter);
      final f = int.tryParse(_frameSpindles);
      final sl = double.tryParse(_shiftLength);

      if (c == null || s == null || t == null || b == null || r == null || d == null || f == null || sl == null) {
        return;
      }

      _result = RingDoffCalculator.calculate(
        yarnCountNe: c,
        spindleSpeedRpm: s,
        tpiValue: t,
        bobbinWeightG: b,
        rovingPackageWeightG: r,
        ringCupDiameterMm: d,
        frameSpindles: f,
        shiftHours: sl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuto = _calcMode == 'Auto from count';

    return PageScaffold(
      title: 'Ring Doff & Roving Consumption',
      subtitle: 'Ring doff time, roving packages consumed per day/shift/doff, OPS and yarn production',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: InputCard(
              title: 'Inputs',
              child: Column(
                children: [
                  StyledTextField(
                    label: 'Yarn count (Ne)',
                    isNumber: true,
                    onChanged: (val) {
                      _yarnCount = val;
                      _calculate();
                    },
                  ),
                  const SizedBox(height: 16),
                  StyledDropdown<String>(
                    label: 'Calculation mode',
                    value: _calcMode,
                    items: const [
                      DropdownMenuItem(value: 'Auto from count', child: Text('Auto from count')),
                      DropdownMenuItem(value: 'Manual parameters', child: Text('Manual parameters')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        _calcMode = val;
                        _calculate();
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  IgnorePointer(
                    ignoring: isAuto,
                    child: Opacity(
                      opacity: isAuto ? 0.5 : 1.0,
                      child: Column(
                        children: [
                          TextField(
                            controller: _speedCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Spindle speed (RPM)'),
                            onChanged: (val) {
                              _spindleSpeed = val;
                              _calculate();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _tpiCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'TPI'),
                            onChanged: (val) {
                              _tpi = val;
                              _calculate();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _bobbinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Ring bobbin weight (g)'),
                            onChanged: (val) {
                              _ringBobbinWeight = val;
                              _calculate();
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _rovingCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Roving package weight (g)'),
                            onChanged: (val) {
                              _rovingPackageWeight = val;
                              _calculate();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  StyledTextField(
                    label: 'Ring cup diameter (mm)',
                    isNumber: true,
                    onChanged: (val) {
                      _ringCupDiameter = val;
                      _calculate();
                    },
                  ),
                  const SizedBox(height: 16),
                  StyledTextField(
                    label: 'Frame spindles',
                    isNumber: true,
                    onChanged: (val) {
                      _frameSpindles = val;
                      _calculate();
                    },
                  ),
                  const SizedBox(height: 16),
                  StyledTextField(
                    label: 'Shift length (hours)',
                    isNumber: true,
                    onChanged: (val) {
                      _shiftLength = val;
                      _calculate();
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_warningMsg != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_warningMsg!, style: const TextStyle(color: Colors.orange)),
                  ),
                InputCard(
                  title: 'Ring doff time calculation',
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      ResultTile(label: 'Ring doff time (min)', value: _result?.doffTimeMin.toStringAsFixed(2), highlight: true),
                      ResultTile(label: 'Ring cup diameter (mm)', value: _ringCupDiameter),
                      ResultTile(label: 'Yarn production/spindle/hour (g)', value: _result?.outputPerSpindlePerHourG.toStringAsFixed(2)),
                      ResultTile(label: 'Roving packages per day/frame', value: _result?.rovingPackagesPerDayPerFrame.toStringAsFixed(2), highlight: true),
                      ResultTile(label: 'Roving packages per doff change', value: _result?.rovingPackagesPerDoffChange.toStringAsFixed(2)),
                      ResultTile(label: 'Roving packages per shift/frame', value: _result?.rovingPackagesPerShift.toStringAsFixed(2)),
                      ResultTile(label: 'Yarn production/day/frame (kg)', value: _result?.yarnProductionPerDayPerFrameKg.toStringAsFixed(2), highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                InputCard(
                  title: 'Roving consumption per day',
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      ResultTile(label: 'Time to consume one roving (hours)', value: _result?.timeToConsumeRovingHours.toStringAsFixed(2)),
                      ResultTile(label: 'Days to consume one roving', value: _result?.daysToConsumeRoving.toStringAsFixed(2)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                InputCard(
                  title: 'Intermediate calculations',
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      ResultTile(label: 'TM', value: _result?.tm.toStringAsFixed(2)),
                      ResultTile(label: 'OPS (oz/spindle/shift)', value: _result?.ops.toStringAsFixed(2), highlight: true),
                      ResultTile(label: 'Doff run time (min)', value: _result?.doffTimeMin.toStringAsFixed(2)),
                      ResultTile(label: 'Doffs/day', value: _result?.doffsPerDay.toStringAsFixed(2)),
                      ResultTile(label: 'Output/spindle/hour (g)', value: _result?.outputPerSpindlePerHourG.toStringAsFixed(2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
