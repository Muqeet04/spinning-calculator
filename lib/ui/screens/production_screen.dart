import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../widgets/pdf_report_helpers.dart';
import '../widgets/responsive_layout.dart';

class ProductionScreen extends StatefulWidget {
  const ProductionScreen({super.key});

  @override
  State<ProductionScreen> createState() => _ProductionScreenState();
}

class _ProductionScreenState extends State<ProductionScreen> {
  String _department = 'Ring frame (spinning)';
  final List<String> _departments = [
    'Carding',
    'Draw frame',
    'Comber',
    'Simplex (speed frame)',
    'Ring frame (spinning)',
    'Winding (autoconer)'
  ];

  // Common inputs
  late TextEditingController _effCtrl;
  late TextEditingController _shiftHoursCtrl;
  late TextEditingController _bagWtCtrl;
  late TextEditingController _shiftsDayCtrl;

  // Ring Frame
  late TextEditingController _rfSpindleSpeedCtrl;
  late TextEditingController _rfCountCtrl;
  late TextEditingController _rfTmCtrl;
  late TextEditingController _rfSpindlesCtrl;

  // Carding
  late TextEditingController _cardSpeedCtrl;
  late TextEditingController _cardSliverCtrl;
  late TextEditingController _cardCardsCtrl;

  // Draw Frame
  late TextEditingController _dfSpeedCtrl;
  late TextEditingController _dfSliverCtrl;
  late TextEditingController _dfDeliveriesCtrl;

  // Comber
  late TextEditingController _cmbNipsCtrl;
  late TextEditingController _cmbFeedLengthCtrl;
  late TextEditingController _cmbNoilCtrl;
  late TextEditingController _cmbHeadsCtrl;
  late TextEditingController _cmbCombersCtrl;
  late TextEditingController _cmbLapWtCtrl;

  // Simplex
  late TextEditingController _spxFlyerSpeedCtrl;
  late TextEditingController _spxTpiCtrl;
  late TextEditingController _spxHankCtrl;
  late TextEditingController _spxSpindlesCtrl;
  late TextEditingController _spxFramesCtrl;

  // Winding
  late TextEditingController _wndSpeedCtrl;
  late TextEditingController _wndCountCtrl;
  late TextEditingController _wndSpindlesCtrl;

  @override
  void initState() {
    super.initState();
    _effCtrl = TextEditingController(text: '95');
    _shiftHoursCtrl = TextEditingController(text: '8');
    _bagWtCtrl = TextEditingController(text: '45.36');
    _shiftsDayCtrl = TextEditingController(text: '3');

    _rfSpindleSpeedCtrl = TextEditingController(text: '22000');
    _rfCountCtrl = TextEditingController(text: '40');
    _rfTmCtrl = TextEditingController(text: '3.6');
    _rfSpindlesCtrl = TextEditingController(text: '1824');

    _cardSpeedCtrl = TextEditingController(text: '200');
    _cardSliverCtrl = TextEditingController(text: '60');
    _cardCardsCtrl = TextEditingController(text: '1');

    _dfSpeedCtrl = TextEditingController(text: '450');
    _dfSliverCtrl = TextEditingController(text: '70');
    _dfDeliveriesCtrl = TextEditingController(text: '1');

    _cmbNipsCtrl = TextEditingController(text: '475');
    _cmbFeedLengthCtrl = TextEditingController(text: '5.2');
    _cmbNoilCtrl = TextEditingController(text: '18');
    _cmbHeadsCtrl = TextEditingController(text: '8');
    _cmbCombersCtrl = TextEditingController(text: '1');
    _cmbLapWtCtrl = TextEditingController(text: '1000');

    _spxFlyerSpeedCtrl = TextEditingController(text: '1200');
    _spxTpiCtrl = TextEditingController(text: '1.3');
    _spxHankCtrl = TextEditingController(text: '0.95');
    _spxSpindlesCtrl = TextEditingController(text: '144');
    _spxFramesCtrl = TextEditingController(text: '1');

    _wndSpeedCtrl = TextEditingController(text: '1400');
    _wndCountCtrl = TextEditingController(text: '40');
    _wndSpindlesCtrl = TextEditingController(text: '60');
  }

  void _onDepartmentChanged(String? newValue) {
    if (newValue == null) return;
    setState(() {
      _department = newValue;
      switch (newValue) {
        case 'Ring frame (spinning)':
          _effCtrl.text = '95';
          break;
        case 'Carding':
          _effCtrl.text = '88';
          break;
        case 'Draw frame':
          _effCtrl.text = '85';
          break;
        case 'Comber':
          _effCtrl.text = '88';
          break;
        case 'Simplex (speed frame)':
          _effCtrl.text = '88';
          break;
        case 'Winding (autoconer)':
          _effCtrl.text = '68';
          break;
      }
    });
  }

  double _val(TextEditingController ctrl) {
    return double.tryParse(ctrl.text) ?? 0.0;
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final widgets = <pw.Widget>[];

    // Department section
    widgets.add(PdfReportHelpers.sectionTitle('Department: $_department'));

    final commonInputs = <String, String>{
      'Efficiency': '${_effCtrl.text}%',
      'Shift Hours': '${_shiftHoursCtrl.text} hrs',
      'Bag Weight': '${_bagWtCtrl.text} kg',
      'Shifts / Day': _shiftsDayCtrl.text,
    };

    final deptInputs = <String, String>{};
    final calculatedResults = <String, String>{};

    final eff = _val(_effCtrl) / 100.0;
    final hrs = _val(_shiftHoursCtrl);
    final bagKg = _val(_bagWtCtrl);
    final bagLbs = bagKg / 0.453592;
    final shifts = _val(_shiftsDayCtrl);

    if (_department == 'Ring frame (spinning)') {
      deptInputs['Spindle Speed'] = '${_rfSpindleSpeedCtrl.text} RPM';
      deptInputs['Count (Ne)'] = _rfCountCtrl.text;
      deptInputs['Twist Multiplier (TM)'] = _rfTmCtrl.text;
      deptInputs['Total Spindles'] = _rfSpindlesCtrl.text;

      final rpm = _val(_rfSpindleSpeedCtrl);
      final count = _val(_rfCountCtrl);
      final tm = _val(_rfTmCtrl);
      final spindles = _val(_rfSpindlesCtrl);

      final tpi = count > 0 ? tm * math.sqrt(count) : 0.0;
      final ops = (tpi > 0 && count > 0)
          ? (rpm * 60 * hrs * eff) / (tpi * 36 * count * 840) * 16
          : 0.0;
      final lbsShift = ops * spindles / 16;
      final kgShift = lbsShift * 0.453592;
      final bagsDay = bagLbs > 0 ? (lbsShift * shifts) / bagLbs : 0.0;

      calculatedResults['TPI'] = tpi.toStringAsFixed(2);
      calculatedResults['OPS (oz/spl/shift)'] = ops.toStringAsFixed(2);
      calculatedResults['Lbs / shift'] = lbsShift.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    } else if (_department == 'Carding') {
      deptInputs['Delivery Speed'] = '${_cardSpeedCtrl.text} m/min';
      deptInputs['Sliver Weight'] = '${_cardSliverCtrl.text} gr/yd';
      deptInputs['No. of Cards'] = _cardCardsCtrl.text;

      final speed = _val(_cardSpeedCtrl);
      final sliverWt = _val(_cardSliverCtrl);
      final cards = _val(_cardCardsCtrl);

      final outputYardsShift = speed * 1.0936 * 60 * hrs * eff;
      final outputLbsShift = (outputYardsShift * sliverWt) / 7000;
      final totalLbs = outputLbsShift * cards;
      final kgShift = totalLbs * 0.453592;
      final bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0.0;

      calculatedResults['Lbs / shift'] = totalLbs.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    } else if (_department == 'Draw frame') {
      deptInputs['Delivery Speed'] = '${_dfSpeedCtrl.text} m/min';
      deptInputs['Sliver Weight'] = '${_dfSliverCtrl.text} gr/yd';
      deptInputs['Deliveries'] = _dfDeliveriesCtrl.text;

      final speed = _val(_dfSpeedCtrl);
      final sliverWt = _val(_dfSliverCtrl);
      final deliveries = _val(_dfDeliveriesCtrl);

      final outputYardsShift = speed * 1.0936 * 60 * hrs * eff;
      final outputLbsShift = (outputYardsShift * sliverWt) / 7000;
      final totalLbs = outputLbsShift * deliveries;
      final kgShift = totalLbs * 0.453592;
      final bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0.0;

      calculatedResults['Lbs / shift'] = totalLbs.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    } else if (_department == 'Comber') {
      deptInputs['Nips / min'] = _cmbNipsCtrl.text;
      deptInputs['Feed Length'] = '${_cmbFeedLengthCtrl.text} mm';
      deptInputs['Noil %'] = '${_cmbNoilCtrl.text}%';
      deptInputs['Heads'] = _cmbHeadsCtrl.text;
      deptInputs['Combers'] = _cmbCombersCtrl.text;
      deptInputs['Lap Weight'] = '${_cmbLapWtCtrl.text} gr/yd';

      final nips = _val(_cmbNipsCtrl);
      final feedLength = _val(_cmbFeedLengthCtrl);
      final noilPct = _val(_cmbNoilCtrl);
      final heads = _val(_cmbHeadsCtrl);
      final combers = _val(_cmbCombersCtrl);
      final lapWt = _val(_cmbLapWtCtrl);

      final lbsHrHead =
          (nips * feedLength / 1000 * 1.0936 * 60 * lapWt / 7000) *
              eff *
              (100 - noilPct) /
              100;
      final totalLbs = lbsHrHead * hrs * heads * combers;
      final noilLbs =
          (100 - noilPct) > 0 ? (totalLbs / (100 - noilPct)) * noilPct : 0.0;
      final kgShift = totalLbs * 0.453592;
      final bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0.0;

      calculatedResults['Lbs / shift'] = totalLbs.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Noil Lbs / shift'] = noilLbs.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    } else if (_department == 'Simplex (speed frame)') {
      deptInputs['Flyer Speed'] = '${_spxFlyerSpeedCtrl.text} RPM';
      deptInputs['TPI'] = _spxTpiCtrl.text;
      deptInputs['Hank Roving'] = _spxHankCtrl.text;
      deptInputs['Spindles'] = _spxSpindlesCtrl.text;
      deptInputs['Frames'] = _spxFramesCtrl.text;

      final flyerSpeed = _val(_spxFlyerSpeedCtrl);
      final tpi = _val(_spxTpiCtrl);
      final hankRoving = _val(_spxHankCtrl);
      final spindles = _val(_spxSpindlesCtrl);
      final frames = _val(_spxFramesCtrl);

      final lbsSpindleShift = (tpi > 0 && hankRoving > 0)
          ? (flyerSpeed / tpi / 36 / 840 * 60 * hrs * eff) / hankRoving
          : 0.0;
      final totalLbs = lbsSpindleShift * spindles * frames;
      final kgShift = totalLbs * 0.453592;
      final bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0.0;

      calculatedResults['Lbs / shift'] = totalLbs.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    } else if (_department == 'Winding (autoconer)') {
      deptInputs['Winding Speed'] = '${_wndSpeedCtrl.text} m/min';
      deptInputs['Count (Ne)'] = _wndCountCtrl.text;
      deptInputs['Spindles'] = _wndSpindlesCtrl.text;

      final speed = _val(_wndSpeedCtrl);
      final count = _val(_wndCountCtrl);
      final spindles = _val(_wndSpindlesCtrl);

      final deliveryYardsMin = speed * 1.0936;
      final hanksMin = deliveryYardsMin / 840;
      final lbsMinSpindle = count > 0 ? hanksMin / count : 0.0;
      final lbsSpindleShift = lbsMinSpindle * 60 * hrs * eff;
      final totalLbs = lbsSpindleShift * spindles;
      final kgShift = totalLbs * 0.453592;
      final bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0.0;

      calculatedResults['Lbs / spl / shift'] =
          lbsSpindleShift.toStringAsFixed(2);
      calculatedResults['Lbs / shift'] = totalLbs.toStringAsFixed(2);
      calculatedResults['Kg / shift'] = kgShift.toStringAsFixed(2);
      calculatedResults['Bags / day'] = bagsDay.toStringAsFixed(2);
    }

    // Add inputs
    widgets.add(PdfReportHelpers.sectionTitle('1. Input Parameters'));
    final allInputs = {...deptInputs, ...commonInputs};
    widgets.add(PdfReportHelpers.keyValGrid(allInputs));
    widgets.add(pw.SizedBox(height: 12));

    // Add results
    widgets
        .add(PdfReportHelpers.sectionTitle('2. Computed Production Results'));
    widgets.add(
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: calculatedResults.entries.map((e) {
          final isBags = e.key.toLowerCase().contains('bags');
          return PdfReportHelpers.summaryCard(e.key, e.value,
              highlight: isBags);
        }).toList(),
      ),
    );

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Production Calculation',
      subtitle: 'Carding, draw frame, comber, simplex, ring frame, winding',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: StyledDropdown<String>(
              label: 'Department',
              value: _department,
              items: _departments
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: _onDepartmentChanged,
            ),
          ),
          const SizedBox(height: 24),
          ResponsiveRow(
            breakpoint: 900,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: InputCard(
                  title: 'Parameters',
                  child: _buildInputs(),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: InputCard(
                  title: 'Results',
                  child: _buildResults(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    List<Widget> fields = [];

    Widget addField(String label, TextEditingController ctrl) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StyledTextField(
            label: label,
            controller: ctrl,
            isNumber: true,
            onChanged: (v) => setState(() {}),
          ),
        ),
      );
    }

    Widget rowOf(List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ResponsiveRow(children: children),
      );
    }

    if (_department == 'Ring frame (spinning)') {
      fields = [
        rowOf([
          addField('Spindle speed (RPM)', _rfSpindleSpeedCtrl),
          addField('Count (Ne)', _rfCountCtrl),
        ]),
        rowOf([
          addField('Twist multiplier (TM)', _rfTmCtrl),
          addField('No. of spindles', _rfSpindlesCtrl),
        ]),
      ];
    } else if (_department == 'Carding') {
      fields = [
        rowOf([
          addField('Delivery speed (m/min)', _cardSpeedCtrl),
          addField('Sliver weight (grains/yard)', _cardSliverCtrl),
        ]),
        rowOf([
          addField('No. of cards', _cardCardsCtrl),
          Expanded(child: Container()),
        ]),
      ];
    } else if (_department == 'Draw frame') {
      fields = [
        rowOf([
          addField('Delivery speed (m/min)', _dfSpeedCtrl),
          addField('Sliver weight (grains/yard)', _dfSliverCtrl),
        ]),
        rowOf([
          addField('No. of deliveries', _dfDeliveriesCtrl),
          Expanded(child: Container()),
        ]),
      ];
    } else if (_department == 'Comber') {
      fields = [
        rowOf([
          addField('Nips per minute', _cmbNipsCtrl),
          addField('Feed length (mm)', _cmbFeedLengthCtrl),
        ]),
        rowOf([
          addField('Noil %', _cmbNoilCtrl),
          addField('Lap weight (grains/yard)', _cmbLapWtCtrl),
        ]),
        rowOf([
          addField('No. of heads', _cmbHeadsCtrl),
          addField('No. of combers', _cmbCombersCtrl),
        ]),
      ];
    } else if (_department == 'Simplex (speed frame)') {
      fields = [
        rowOf([
          addField('Flyer speed (RPM)', _spxFlyerSpeedCtrl),
          addField('TPI', _spxTpiCtrl),
        ]),
        rowOf([
          addField('Hank of roving', _spxHankCtrl),
          addField('No. of spindles', _spxSpindlesCtrl),
        ]),
        rowOf([
          addField('No. of frames', _spxFramesCtrl),
          Expanded(child: Container()),
        ]),
      ];
    } else if (_department == 'Winding (autoconer)') {
      fields = [
        rowOf([
          addField('Winding speed (m/min)', _wndSpeedCtrl),
          addField('Count (Ne)', _wndCountCtrl),
        ]),
        rowOf([
          addField('No. of spindles', _wndSpindlesCtrl),
          Expanded(child: Container()),
        ]),
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...fields,
        const Divider(height: 32),
        const Text(
          'Common Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        rowOf([
          addField('Efficiency (%)', _effCtrl),
          addField('Shift hours', _shiftHoursCtrl),
        ]),
        rowOf([
          addField('Bag weight (kg)', _bagWtCtrl),
          addField('Shifts/day', _shiftsDayCtrl),
        ]),
      ],
    );
  }

  Widget _buildResults() {
    double eff = _val(_effCtrl) / 100.0;
    double hrs = _val(_shiftHoursCtrl);
    double bagKg = _val(_bagWtCtrl);
    double bagLbs = bagKg / 0.453592;
    double shifts = _val(_shiftsDayCtrl);

    List<Widget> tiles = [];

    if (_department == 'Ring frame (spinning)') {
      double speed = _val(_rfSpindleSpeedCtrl);
      double count = _val(_rfCountCtrl);
      double tm = _val(_rfTmCtrl);
      double spindles = _val(_rfSpindlesCtrl);

      double tpi = count > 0 ? tm * math.sqrt(count) : 0;
      double ops = (tpi > 0 && count > 0)
          ? (speed * 60 * hrs * eff) / (tpi * 36 * count * 840) * 16
          : 0;
      double lbsShift = (ops * spindles) / 16;
      double kgShift = lbsShift * 0.453592;
      double bagsDay = bagLbs > 0 ? (lbsShift * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(label: 'TPI', value: tpi.toStringAsFixed(2)),
        ResultTile(label: 'OPS (oz/spl/shift)', value: ops.toStringAsFixed(2)),
        ResultTile(label: 'Lbs/shift', value: lbsShift.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    } else if (_department == 'Carding') {
      double speed = _val(_cardSpeedCtrl);
      double sliverWt = _val(_cardSliverCtrl);
      double cards = _val(_cardCardsCtrl);

      double outputYardsMin = speed * 1.0936;
      double outputYardsShift = outputYardsMin * 60 * hrs * eff;
      double outputLbsShift = (outputYardsShift * sliverWt) / 7000;
      double totalLbs = outputLbsShift * cards;
      double kgShift = totalLbs * 0.453592;
      double bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(label: 'Lbs/shift', value: totalLbs.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    } else if (_department == 'Draw frame') {
      double speed = _val(_dfSpeedCtrl);
      double sliverWt = _val(_dfSliverCtrl);
      double deliveries = _val(_dfDeliveriesCtrl);

      double outputYardsMin = speed * 1.0936;
      double outputYardsShift = outputYardsMin * 60 * hrs * eff;
      double outputLbsShift = (outputYardsShift * sliverWt) / 7000;
      double totalLbs = outputLbsShift * deliveries;
      double kgShift = totalLbs * 0.453592;
      double bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(label: 'Lbs/shift', value: totalLbs.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    } else if (_department == 'Comber') {
      double nips = _val(_cmbNipsCtrl);
      double feedLength = _val(_cmbFeedLengthCtrl);
      double noilPct = _val(_cmbNoilCtrl);
      double heads = _val(_cmbHeadsCtrl);
      double combers = _val(_cmbCombersCtrl);
      double lapWt = _val(_cmbLapWtCtrl);

      double lbsHrHead =
          (nips * feedLength / 1000 * 1.0936 * 60 * lapWt / 7000) *
              eff *
              (100 - noilPct) /
              100;
      double totalLbs = lbsHrHead * hrs * heads * combers;
      double noilLbs =
          (100 - noilPct) > 0 ? (totalLbs / (100 - noilPct)) * noilPct : 0;
      double kgShift = totalLbs * 0.453592;
      double bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(label: 'Lbs/shift', value: totalLbs.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(label: 'Noil lbs/shift', value: noilLbs.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    } else if (_department == 'Simplex (speed frame)') {
      double flyerSpeed = _val(_spxFlyerSpeedCtrl);
      double tpi = _val(_spxTpiCtrl);
      double hankRoving = _val(_spxHankCtrl);
      double spindles = _val(_spxSpindlesCtrl);
      double frames = _val(_spxFramesCtrl);

      double lbsSpindleShift = (tpi > 0 && hankRoving > 0)
          ? (flyerSpeed / tpi / 36 / 840 * 60 * hrs * eff) / hankRoving
          : 0;
      double totalLbs = lbsSpindleShift * spindles * frames;
      double kgShift = totalLbs * 0.453592;
      double bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(label: 'Lbs/shift', value: totalLbs.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    } else if (_department == 'Winding (autoconer)') {
      double speed = _val(_wndSpeedCtrl);
      double count = _val(_wndCountCtrl);
      double spindles = _val(_wndSpindlesCtrl);

      double deliveryYardsMin = speed * 1.0936;
      double hanksMin = deliveryYardsMin / 840;
      double lbsMinSpindle = count > 0 ? hanksMin / count : 0;
      double lbsSpindleShift = lbsMinSpindle * 60 * hrs * eff;
      double totalLbs = lbsSpindleShift * spindles;
      double kgShift = totalLbs * 0.453592;
      double bagsDay = bagLbs > 0 ? (totalLbs * shifts) / bagLbs : 0;

      tiles = [
        ResultTile(
            label: 'Lbs/spl/shift', value: lbsSpindleShift.toStringAsFixed(2)),
        ResultTile(label: 'Lbs/shift', value: totalLbs.toStringAsFixed(2)),
        ResultTile(label: 'Kg/shift', value: kgShift.toStringAsFixed(2)),
        ResultTile(
            label: 'Bags/day',
            value: bagsDay.toStringAsFixed(2),
            highlight: true),
      ];
    }

    return ResponsiveResults(
      children: tiles,
    );
  }

  @override
  void dispose() {
    _effCtrl.dispose();
    _shiftHoursCtrl.dispose();
    _bagWtCtrl.dispose();
    _shiftsDayCtrl.dispose();

    _rfSpindleSpeedCtrl.dispose();
    _rfCountCtrl.dispose();
    _rfTmCtrl.dispose();
    _rfSpindlesCtrl.dispose();

    _cardSpeedCtrl.dispose();
    _cardSliverCtrl.dispose();
    _cardCardsCtrl.dispose();

    _dfSpeedCtrl.dispose();
    _dfSliverCtrl.dispose();
    _dfDeliveriesCtrl.dispose();

    _cmbNipsCtrl.dispose();
    _cmbFeedLengthCtrl.dispose();
    _cmbNoilCtrl.dispose();
    _cmbHeadsCtrl.dispose();
    _cmbCombersCtrl.dispose();
    _cmbLapWtCtrl.dispose();

    _spxFlyerSpeedCtrl.dispose();
    _spxTpiCtrl.dispose();
    _spxHankCtrl.dispose();
    _spxSpindlesCtrl.dispose();
    _spxFramesCtrl.dispose();

    _wndSpeedCtrl.dispose();
    _wndCountCtrl.dispose();
    _wndSpindlesCtrl.dispose();

    super.dispose();
  }
}
