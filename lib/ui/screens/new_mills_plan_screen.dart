import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';

class NewMillsPlanScreen extends ConsumerStatefulWidget {
  const NewMillsPlanScreen({super.key});

  @override
  ConsumerState<NewMillsPlanScreen> createState() => _NewMillsPlanScreenState();
}

class _NewMillsPlanScreenState extends ConsumerState<NewMillsPlanScreen> {
  final _millNameCtrl = TextEditingController();
  final _spindlesCtrl = TextEditingController(text: '1824');
  final _bagWeightCtrl = TextEditingController(text: '100');
  final _hoursCtrl = TextEditingController(text: '24');

  String _cardFeed = 'Wider (100 kg/hr)';
  String _flyer = 'New faster (1200)';
  String _combers = 'New (475–500 nips/min)';
  String _lapFormer = 'New (150 m/min)';
  String _winders = 'New (1400 m/min)';
  String _matchBags = 'Reducing speed (whole machines)';

  @override
  void dispose() {
    _millNameCtrl.dispose();
    _spindlesCtrl.dispose();
    _bagWeightCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'New mills plan',
      subtitle: 'From required bags to machines and speeds across all spinning departments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: '0. Mill Setup',
            child: Column(
              children: [
                StyledTextField(controller: _millNameCtrl, label: 'Mill Name'),
                const SizedBox(height: 12),
                StyledTextField(controller: _spindlesCtrl, label: 'Spindles/Frame (Ring)', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Card Feed Width',
                  value: _cardFeed,
                  items: const [
                    DropdownMenuItem(value: 'Wider (100 kg/hr)', child: Text('Wider (100 kg/hr)')),
                    DropdownMenuItem(value: 'Narrow (55 kg/hr)', child: Text('Narrow (55 kg/hr)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _cardFeed = v); },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Flyer',
                  value: _flyer,
                  items: const [
                    DropdownMenuItem(value: 'New faster (1200)', child: Text('New faster (1200)')),
                    DropdownMenuItem(value: 'Old (1000)', child: Text('Old (1000)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _flyer = v); },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Combers',
                  value: _combers,
                  items: const [
                    DropdownMenuItem(value: 'New (475–500 nips/min)', child: Text('New (475–500 nips/min)')),
                    DropdownMenuItem(value: 'Old (400 nips/min)', child: Text('Old (400 nips/min)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _combers = v); },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Lap Former',
                  value: _lapFormer,
                  items: const [
                    DropdownMenuItem(value: 'New (150 m/min)', child: Text('New (150 m/min)')),
                    DropdownMenuItem(value: 'Old (100 m/min)', child: Text('Old (100 m/min)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _lapFormer = v); },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Winders',
                  value: _winders,
                  items: const [
                    DropdownMenuItem(value: 'New (1400 m/min)', child: Text('New (1400 m/min)')),
                    DropdownMenuItem(value: 'Old (1000 m/min)', child: Text('Old (1000 m/min)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _winders = v); },
                ),
                const SizedBox(height: 12),
                StyledTextField(controller: _bagWeightCtrl, label: 'Bag weight lbs', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(controller: _hoursCtrl, label: 'Working hours/day', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Match actual bags to required by',
                  value: _matchBags,
                  items: const [
                    DropdownMenuItem(value: 'Reducing speed (whole machines)', child: Text('Reducing speed (whole machines)')),
                    DropdownMenuItem(value: 'Decimal machines (full speed)', child: Text('Decimal machines (full speed)')),
                  ],
                  onChanged: (v) { if (v != null) setState(() => _matchBags = v); },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '1. Bags Required',
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Quality')),
                      DataColumn(label: Text('Application')),
                      DataColumn(label: Text('Count')),
                      DataColumn(label: Text('Bags Req.')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(Text('Combed')),
                        DataCell(Text('Warp')),
                        DataCell(Text('40')),
                        DataCell(Text('100')),
                        DataCell(Icon(Icons.delete, color: Colors.red)),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Carded')),
                        DataCell(Text('Warp')),
                        DataCell(Text('30')),
                        DataCell(Text('100')),
                        DataCell(Icon(Icons.delete, color: Colors.red)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add count'),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ResultTile(label: 'Combed Bags Total', value: '100'),
                    ResultTile(label: 'Carded Bags Total', value: '100'),
                    ResultTile(label: 'Total Bags Required', value: '200', highlight: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '2. Ring & Autocone',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Count')),
                  DataColumn(label: Text('Req.Bags')),
                  DataColumn(label: Text('A.Count')),
                  DataColumn(label: Text('TM')),
                  DataColumn(label: Text('TPI')),
                  DataColumn(label: Text('Spindle Speed')),
                  DataColumn(label: Text('Eff%')),
                  DataColumn(label: Text('OPS')),
                  DataColumn(label: Text('Bags/Frame')),
                  DataColumn(label: Text('Frames Req.')),
                  DataColumn(label: Text('Ring Spindles Req.')),
                  DataColumn(label: Text('Actual Bags (Ring)')),
                  DataColumn(label: Text('W.Speed')),
                  DataColumn(label: Text('A.Cone Eff%')),
                  DataColumn(label: Text('Winder Spindles Req.')),
                  DataColumn(label: Text('Actual Bags (Winder)')),
                ],
                rows: const [],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '3. Simplex',
            child: Column(
              children: [
                ResultTile(label: 'Req. Roving Bags', value: '206'),
                ResultTile(label: 'Simplex machines & flyers required', value: '2 (240 flyers)'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '4. Finisher drawing',
            child: ResultTile(label: 'Machines required', value: '2'),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '5. Comber & Lap former',
            child: Column(
              children: [
                ResultTile(label: 'Combers required', value: '3'),
                ResultTile(label: 'Lap formers required', value: '1'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '6. Breaker drawing',
            child: ResultTile(label: 'Machines required', value: '2'),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '7. Blow room line design',
            child: ResultTile(label: 'Lines required', value: '1'),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '8. Carding',
            child: ResultTile(label: 'Cards required', value: '8'),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '9. Summary table',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Required (machines)')),
                  DataColumn(label: Text('Required Bags')),
                  DataColumn(label: Text('Actual Bags')),
                  DataColumn(label: Text('Difference')),
                ],
                rows: const [
                  DataRow(cells: [DataCell(Text('Ring frames')), DataCell(Text('20')), DataCell(Text('200')), DataCell(Text('200')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Ring spindles')), DataCell(Text('36480')), DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-'))]),
                  DataRow(cells: [DataCell(Text('Autocone spindles')), DataCell(Text('800')), DataCell(Text('-')), DataCell(Text('-')), DataCell(Text('-'))]),
                  DataRow(cells: [DataCell(Text('Simplex (flyers)')), DataCell(Text('240')), DataCell(Text('206')), DataCell(Text('206')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Finisher')), DataCell(Text('2')), DataCell(Text('206')), DataCell(Text('206')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Comber')), DataCell(Text('3')), DataCell(Text('103')), DataCell(Text('103')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Lap former')), DataCell(Text('1')), DataCell(Text('103')), DataCell(Text('103')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Breaker')), DataCell(Text('2')), DataCell(Text('206')), DataCell(Text('206')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Cards')), DataCell(Text('8')), DataCell(Text('206')), DataCell(Text('206')), DataCell(Text('0'))]),
                  DataRow(cells: [DataCell(Text('Blow room lines')), DataCell(Text('1')), DataCell(Text('206')), DataCell(Text('206')), DataCell(Text('0'))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
