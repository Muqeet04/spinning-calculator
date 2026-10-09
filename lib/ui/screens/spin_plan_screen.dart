import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../../app/theme.dart';

class SpinPlanScreen extends ConsumerStatefulWidget {
  const SpinPlanScreen({super.key});

  @override
  ConsumerState<SpinPlanScreen> createState() => _SpinPlanScreenState();
}

class _SpinPlanScreenState extends ConsumerState<SpinPlanScreen> {
  final _millNameCtrl = TextEditingController();
  final _bagWeightCtrl = TextEditingController(text: '100');
  final _hoursCtrl = TextEditingController(text: '24');
  final _blowRoomWasteCtrl = TextEditingController(text: '4');
  final _cardWasteCtrl = TextEditingController(text: '5');
  final _maxSpeedCtrl = TextEditingController(text: '10');

  String _balanceBy = 'Reducing speed';

  @override
  void dispose() {
    _millNameCtrl.dispose();
    _bagWeightCtrl.dispose();
    _hoursCtrl.dispose();
    _blowRoomWasteCtrl.dispose();
    _cardWasteCtrl.dispose();
    _maxSpeedCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Spin plan — auto-balance',
      subtitle: 'Balance every spinning department from ring frame backward',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: '0. Plant Setup',
            child: Column(
              children: [
                StyledTextField(controller: _millNameCtrl, label: 'Mill Name'),
                const SizedBox(height: 12),
                StyledTextField(controller: _bagWeightCtrl, label: 'Bag weight lbs', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(controller: _hoursCtrl, label: 'Working hours/day', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(controller: _blowRoomWasteCtrl, label: 'Blow room waste %', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(controller: _cardWasteCtrl, label: 'Card waste %', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Balance by',
                  value: _balanceBy,
                  items: const [
                    DropdownMenuItem(value: 'Reducing speed', child: Text('Reducing speed')),
                    DropdownMenuItem(value: 'Increasing speed', child: Text('Increasing speed')),
                    DropdownMenuItem(value: 'Decimal machines', child: Text('Decimal machines')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _balanceBy = v); },
                ),
                const SizedBox(height: 12),
                StyledTextField(controller: _maxSpeedCtrl, label: 'Max speed increase allowed %', keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '1. Ring frames count-wise',
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Count')),
                      DataColumn(label: Text('Quality')),
                      DataColumn(label: Text('Application')),
                      DataColumn(label: Text('Compact')),
                      DataColumn(label: Text('Blend')),
                      DataColumn(label: Text('Frames')),
                      DataColumn(label: Text('Spindles/Frame')),
                      DataColumn(label: Text('OPS')),
                      DataColumn(label: Text('Total spindles')),
                      DataColumn(label: Text('Bags/day')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('40')),
                        DataCell(Text('Combed')),
                        DataCell(Text('Warp')),
                        DataCell(Text('No')),
                        DataCell(Text('1')),
                        DataCell(Text('10')),
                        DataCell(Text('1824')),
                        DataCell(Text('6.02')),
                        DataCell(Text('18240')),
                        DataCell(Text('100')),
                        DataCell(Icon(Icons.delete, color: Colors.red)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const ResultTile(label: 'Combed bags/day', value: '100'),
                const ResultTile(label: 'Carded bags/day', value: '0'),
                const ResultTile(label: 'Total bags/day', value: '100', highlight: true),
                const ResultTile(label: 'Total frames', value: '10'),
                const ResultTile(label: 'Total spindles', value: '18240'),
                const ResultTile(label: 'Winder spindles needed', value: '400'),
                const ResultTile(label: 'Average count', value: '40'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '2. Machines available (fleet inputs)',
            child: Column(
              children: [
                StyledTextField(controller: TextEditingController(text: '400'), label: 'Autocone spindles', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '18240'), label: 'Ring spindles', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '240'), label: 'Simplex flyers', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '2'), label: 'Drawing finisher', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '3'), label: 'Combers', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '1'), label: 'Lap former', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '2'), label: 'Breakers', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '8'), label: 'Cards', keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(controller: TextEditingController(text: '1'), label: 'Blow room lines', keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '3. Balanced plan by department',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Required bags/day')),
                  DataColumn(label: Text('Machines needed')),
                  DataColumn(label: Text('Available')),
                  DataColumn(label: Text('In plan')),
                  DataColumn(label: Text('Efficiency %')),
                  DataColumn(label: Text('Set speed')),
                  DataColumn(label: Text('Production balanced')),
                  DataColumn(label: Text('Run speed (% of set)')),
                  DataColumn(label: Text('Actual bags/day')),
                  DataColumn(label: Text('Diff')),
                  DataColumn(label: Text('Status')),
                ],
                rows: const [
                  DataRow(cells: [DataCell(Text('Blow room lines')), DataCell(Text('109')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('80')), DataCell(Text('1000')), DataCell(Text('109')), DataCell(Text('90%')), DataCell(Text('109')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Cards')), DataCell(Text('109')), DataCell(Text('4')), DataCell(Text('8')), DataCell(Text('4')), DataCell(Text('90')), DataCell(Text('55')), DataCell(Text('109')), DataCell(Text('100%')), DataCell(Text('109')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Breaker drawing')), DataCell(Text('103')), DataCell(Text('1')), DataCell(Text('2')), DataCell(Text('1')), DataCell(Text('85')), DataCell(Text('500')), DataCell(Text('103')), DataCell(Text('100%')), DataCell(Text('103')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Lap former')), DataCell(Text('103')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('80')), DataCell(Text('150')), DataCell(Text('103')), DataCell(Text('100%')), DataCell(Text('103')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Comber')), DataCell(Text('103')), DataCell(Text('2')), DataCell(Text('3')), DataCell(Text('2')), DataCell(Text('90')), DataCell(Text('475')), DataCell(Text('103')), DataCell(Text('100%')), DataCell(Text('103')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Finisher drawing')), DataCell(Text('103')), DataCell(Text('1')), DataCell(Text('2')), DataCell(Text('1')), DataCell(Text('85')), DataCell(Text('500')), DataCell(Text('103')), DataCell(Text('100%')), DataCell(Text('103')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Simplex')), DataCell(Text('103')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('1')), DataCell(Text('85')), DataCell(Text('1200')), DataCell(Text('103')), DataCell(Text('100%')), DataCell(Text('103')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Ring frames')), DataCell(Text('100')), DataCell(Text('10')), DataCell(Text('10')), DataCell(Text('10')), DataCell(Text('90')), DataCell(Text('20000')), DataCell(Text('100')), DataCell(Text('100%')), DataCell(Text('100')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                  DataRow(cells: [DataCell(Text('Autocone winders')), DataCell(Text('100')), DataCell(Text('400')), DataCell(Text('400')), DataCell(Text('400')), DataCell(Text('75')), DataCell(Text('1400')), DataCell(Text('100')), DataCell(Text('100%')), DataCell(Text('100')), DataCell(Text('0')), DataCell(Text('OK', style: TextStyle(color: Colors.green)))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '4. Count-wise spin plan summary',
            child: Center(child: Text('Summary table would go here', style: TextStyle(color: SpinColors.bodyText))),
          ),
        ],
      ),
    );
  }
}
