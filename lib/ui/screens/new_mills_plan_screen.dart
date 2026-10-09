import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../widgets/pdf_report_helpers.dart';
import '../widgets/responsive_layout.dart';

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

  static const _summaryRows = <List<String>>[
    ['Ring frames', '20', '200', '200', '0'],
    ['Ring spindles', '36480', '-', '-', '-'],
    ['Autocone spindles', '800', '-', '-', '-'],
    ['Simplex (flyers)', '240', '206', '206', '0'],
    ['Finisher', '2', '206', '206', '0'],
    ['Comber', '3', '103', '103', '0'],
    ['Lap former', '1', '103', '103', '0'],
    ['Breaker', '2', '206', '206', '0'],
    ['Cards', '8', '206', '206', '0'],
    ['Blow room lines', '1', '206', '206', '0'],
  ];

  @override
  void dispose() {
    _millNameCtrl.dispose();
    _spindlesCtrl.dispose();
    _bagWeightCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    return [
      PdfReportHelpers.sectionTitle('0. Mill Setup - Current Inputs'),
      PdfReportHelpers.keyValGrid({
        'Mill Name': _millNameCtrl.text.isEmpty ? '-' : _millNameCtrl.text,
        'Spindles/Frame (Ring)': _spindlesCtrl.text,
        'Card Feed Width': _cardFeed,
        'Flyer': _flyer,
        'Combers': _combers,
        'Lap Former': _lapFormer,
        'Winders': _winders,
        'Bag weight (lbs)': _bagWeightCtrl.text,
        'Working hours/day': _hoursCtrl.text,
        'Match actual bags to required by': _matchBags,
      }),
      pw.SizedBox(height: 8),
      pw.Text(
        'The following bags, machine requirements and summary values are the sample data currently shown on this page. They are not recalculated from the mill setup inputs.',
        style: const pw.TextStyle(fontSize: 9),
      ),
      PdfReportHelpers.sectionTitle('1. Bags Required - Displayed Sample'),
      PdfReportHelpers.dataTable(
        headers: ['Quality', 'Application', 'Count', 'Bags Req.'],
        rows: const [
          ['Combed', 'Warp', '40', '100'],
          ['Carded', 'Warp', '30', '100'],
        ],
      ),
      PdfReportHelpers.keyValGrid(const {
        'Combed Bags Total': '100',
        'Carded Bags Total': '100',
        'Total Bags Required': '200',
      }),
      PdfReportHelpers.sectionTitle('2. Ring & Autocone'),
      pw.Text('No data rows are currently shown in this table.',
          style: const pw.TextStyle(fontSize: 9)),
      pw.SizedBox(height: 4),
      pw.Text(
        'Columns: Count; Req.Bags; A.Count; TM; TPI; Spindle Speed; Eff%; OPS; Bags/Frame; Frames Req.; Ring Spindles Req.; Actual Bags (Ring); W.Speed; A.Cone Eff%; Winder Spindles Req.; Actual Bags (Winder).',
        style: const pw.TextStyle(fontSize: 8),
      ),
      PdfReportHelpers.sectionTitle('3. Simplex - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {
        'Req. Roving Bags': '206',
        'Simplex machines & flyers required': '2 (240 flyers)',
      }),
      PdfReportHelpers.sectionTitle('4. Finisher Drawing - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {'Machines required': '2'}),
      PdfReportHelpers.sectionTitle(
          '5. Comber & Lap Former - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {
        'Combers required': '3',
        'Lap formers required': '1',
      }),
      PdfReportHelpers.sectionTitle('6. Breaker Drawing - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {'Machines required': '2'}),
      PdfReportHelpers.sectionTitle(
          '7. Blow Room Line Design - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {'Lines required': '1'}),
      PdfReportHelpers.sectionTitle('8. Carding - Displayed Sample'),
      PdfReportHelpers.keyValGrid(const {'Cards required': '8'}),
      PdfReportHelpers.sectionTitle('9. Summary Table - Displayed Sample'),
      PdfReportHelpers.dataTable(
        headers: [
          'Department',
          'Required (machines)',
          'Required Bags',
          'Actual Bags',
          'Difference'
        ],
        rows: _summaryRows,
        flexWidths: [3, 2, 2, 2, 2],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'New mills plan',
      subtitle:
          'From required bags to machines and speeds across all spinning departments',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: '0. Mill Setup',
            child: Column(
              children: [
                StyledTextField(controller: _millNameCtrl, label: 'Mill Name'),
                const SizedBox(height: 12),
                StyledTextField(
                    controller: _spindlesCtrl,
                    label: 'Spindles/Frame (Ring)',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Card Feed Width',
                  value: _cardFeed,
                  items: const [
                    DropdownMenuItem(
                        value: 'Wider (100 kg/hr)',
                        child: Text('Wider (100 kg/hr)')),
                    DropdownMenuItem(
                        value: 'Narrow (55 kg/hr)',
                        child: Text('Narrow (55 kg/hr)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _cardFeed = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Flyer',
                  value: _flyer,
                  items: const [
                    DropdownMenuItem(
                        value: 'New faster (1200)',
                        child: Text('New faster (1200)')),
                    DropdownMenuItem(
                        value: 'Old (1000)', child: Text('Old (1000)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _flyer = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Combers',
                  value: _combers,
                  items: const [
                    DropdownMenuItem(
                        value: 'New (475–500 nips/min)',
                        child: Text('New (475–500 nips/min)')),
                    DropdownMenuItem(
                        value: 'Old (400 nips/min)',
                        child: Text('Old (400 nips/min)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _combers = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Lap Former',
                  value: _lapFormer,
                  items: const [
                    DropdownMenuItem(
                        value: 'New (150 m/min)',
                        child: Text('New (150 m/min)')),
                    DropdownMenuItem(
                        value: 'Old (100 m/min)',
                        child: Text('Old (100 m/min)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _lapFormer = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Winders',
                  value: _winders,
                  items: const [
                    DropdownMenuItem(
                        value: 'New (1400 m/min)',
                        child: Text('New (1400 m/min)')),
                    DropdownMenuItem(
                        value: 'Old (1000 m/min)',
                        child: Text('Old (1000 m/min)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _winders = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledTextField(
                    controller: _bagWeightCtrl,
                    label: 'Bag weight lbs',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(
                    controller: _hoursCtrl,
                    label: 'Working hours/day',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Match actual bags to required by',
                  value: _matchBags,
                  items: const [
                    DropdownMenuItem(
                        value: 'Reducing speed (whole machines)',
                        child: Text('Reducing speed (whole machines)')),
                    DropdownMenuItem(
                        value: 'Decimal machines (full speed)',
                        child: Text('Decimal machines (full speed)')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _matchBags = v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '1. Bags Required',
            child: Column(
              children: [
                ResponsiveTable(
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
                const ResponsiveResults(
                  children: [
                    ResultTile(label: 'Combed Bags Total', value: '100'),
                    ResultTile(label: 'Carded Bags Total', value: '100'),
                    ResultTile(
                        label: 'Total Bags Required',
                        value: '200',
                        highlight: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '2. Ring & Autocone',
            child: ResponsiveTable(
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
                ResultTile(
                    label: 'Simplex machines & flyers required',
                    value: '2 (240 flyers)'),
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
            child: ResponsiveTable(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Required (machines)')),
                  DataColumn(label: Text('Required Bags')),
                  DataColumn(label: Text('Actual Bags')),
                  DataColumn(label: Text('Difference')),
                ],
                rows: _summaryRows
                    .map((row) => DataRow(
                          cells: row
                              .map((value) => DataCell(Text(value)))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
