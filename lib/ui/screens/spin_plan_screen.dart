import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/styled_dropdown.dart';
import '../widgets/pdf_report_helpers.dart';
import '../../app/theme.dart';
import '../widgets/responsive_layout.dart';

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
  final _fleetControllers = <String, TextEditingController>{
    'Autocone spindles': TextEditingController(text: '400'),
    'Ring spindles': TextEditingController(text: '18240'),
    'Simplex flyers': TextEditingController(text: '240'),
    'Drawing finisher': TextEditingController(text: '2'),
    'Combers': TextEditingController(text: '3'),
    'Lap former': TextEditingController(text: '1'),
    'Breakers': TextEditingController(text: '2'),
    'Cards': TextEditingController(text: '8'),
    'Blow room lines': TextEditingController(text: '1'),
  };

  static const _balancedPlanRows = <List<String>>[
    [
      'Blow room lines',
      '109',
      '1',
      '1',
      '1',
      '80',
      '1000',
      '109',
      '90%',
      '109',
      '0',
      'OK'
    ],
    [
      'Cards',
      '109',
      '4',
      '8',
      '4',
      '90',
      '55',
      '109',
      '100%',
      '109',
      '0',
      'OK'
    ],
    [
      'Breaker drawing',
      '103',
      '1',
      '2',
      '1',
      '85',
      '500',
      '103',
      '100%',
      '103',
      '0',
      'OK'
    ],
    [
      'Lap former',
      '103',
      '1',
      '1',
      '1',
      '80',
      '150',
      '103',
      '100%',
      '103',
      '0',
      'OK'
    ],
    [
      'Comber',
      '103',
      '2',
      '3',
      '2',
      '90',
      '475',
      '103',
      '100%',
      '103',
      '0',
      'OK'
    ],
    [
      'Finisher drawing',
      '103',
      '1',
      '2',
      '1',
      '85',
      '500',
      '103',
      '100%',
      '103',
      '0',
      'OK'
    ],
    [
      'Simplex',
      '103',
      '1',
      '1',
      '1',
      '85',
      '1200',
      '103',
      '100%',
      '103',
      '0',
      'OK'
    ],
    [
      'Ring frames',
      '100',
      '10',
      '10',
      '10',
      '90',
      '20000',
      '100',
      '100%',
      '100',
      '0',
      'OK'
    ],
    [
      'Autocone winders',
      '100',
      '400',
      '400',
      '400',
      '75',
      '1400',
      '100',
      '100%',
      '100',
      '0',
      'OK'
    ],
  ];

  String _balanceBy = 'Reducing speed';

  @override
  void dispose() {
    _millNameCtrl.dispose();
    _bagWeightCtrl.dispose();
    _hoursCtrl.dispose();
    _blowRoomWasteCtrl.dispose();
    _cardWasteCtrl.dispose();
    _maxSpeedCtrl.dispose();
    for (final controller in _fleetControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    return [
      PdfReportHelpers.sectionTitle('0. Plant Setup - Current Inputs'),
      PdfReportHelpers.keyValGrid({
        'Mill Name': _millNameCtrl.text.isEmpty ? '-' : _millNameCtrl.text,
        'Bag weight (lbs)': _bagWeightCtrl.text,
        'Working hours/day': _hoursCtrl.text,
        'Blow room waste %': _blowRoomWasteCtrl.text,
        'Card waste %': _cardWasteCtrl.text,
        'Balance by': _balanceBy,
        'Max speed increase allowed %': _maxSpeedCtrl.text,
      }),
      pw.SizedBox(height: 8),
      pw.Text(
        'The following ring-frame, balance and summary values are the sample data currently shown on this page. They are not recalculated from the setup or fleet inputs.',
        style: const pw.TextStyle(fontSize: 9),
      ),
      PdfReportHelpers.sectionTitle(
          '1. Ring Frames Count-wise - Displayed Sample'),
      PdfReportHelpers.dataTable(
        headers: [
          'Count',
          'Quality',
          'Application',
          'Compact',
          'Blend',
          'Frames',
          'Spindles/Frame'
        ],
        rows: const [
          ['40', 'Combed', 'Warp', 'No', '1', '10', '1824']
        ],
      ),
      pw.SizedBox(height: 6),
      PdfReportHelpers.dataTable(
        headers: ['Count', 'OPS', 'Total spindles', 'Bags/day'],
        rows: const [
          ['40', '6.02', '18240', '100']
        ],
      ),
      PdfReportHelpers.keyValGrid(const {
        'Combed bags/day': '100',
        'Carded bags/day': '0',
        'Total bags/day': '100',
        'Total frames': '10',
        'Total spindles': '18240',
        'Winder spindles needed': '400',
        'Average count': '40',
      }),
      PdfReportHelpers.sectionTitle(
          '2. Machines Available - Current Fleet Inputs'),
      PdfReportHelpers.keyValGrid({
        for (final entry in _fleetControllers.entries)
          entry.key: entry.value.text.isEmpty ? '-' : entry.value.text,
      }),
      PdfReportHelpers.sectionTitle(
          '3. Balanced Plan by Department - Displayed Sample'),
      PdfReportHelpers.dataTable(
        headers: [
          'Department',
          'Required bags/day',
          'Machines needed',
          'Available',
          'In plan'
        ],
        rows: _balancedPlanRows.map((row) => row.sublist(0, 5)).toList(),
        flexWidths: [3, 2, 2, 2, 2],
      ),
      pw.SizedBox(height: 6),
      PdfReportHelpers.dataTable(
        headers: [
          'Department',
          'Efficiency %',
          'Set speed',
          'Production balanced',
          'Run speed (% of set)',
          'Actual bags/day',
          'Diff',
          'Status'
        ],
        rows: _balancedPlanRows
            .map((row) => [row.first, ...row.sublist(5)])
            .toList(),
        flexWidths: [3, 1.6, 1.6, 2, 2, 2, 1, 1.2],
      ),
      PdfReportHelpers.sectionTitle('4. Count-wise Spin Plan Summary'),
      pw.Text('Summary table would go here',
          style: const pw.TextStyle(fontSize: 9)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Spin plan — auto-balance',
      subtitle: 'Balance every spinning department from ring frame backward',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: '0. Plant Setup',
            child: Column(
              children: [
                StyledTextField(controller: _millNameCtrl, label: 'Mill Name'),
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
                StyledTextField(
                    controller: _blowRoomWasteCtrl,
                    label: 'Blow room waste %',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledTextField(
                    controller: _cardWasteCtrl,
                    label: 'Card waste %',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                StyledDropdown<String>(
                  label: 'Balance by',
                  value: _balanceBy,
                  items: const [
                    DropdownMenuItem(
                        value: 'Reducing speed', child: Text('Reducing speed')),
                    DropdownMenuItem(
                        value: 'Increasing speed',
                        child: Text('Increasing speed')),
                    DropdownMenuItem(
                        value: 'Decimal machines',
                        child: Text('Decimal machines')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _balanceBy = v);
                  },
                ),
                const SizedBox(height: 12),
                StyledTextField(
                    controller: _maxSpeedCtrl,
                    label: 'Max speed increase allowed %',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '1. Ring frames count-wise',
            child: Column(
              children: [
                ResponsiveTable(
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
                const SizedBox(height: 16),
                const ResponsiveResults(
                  children: [
                    ResultTile(label: 'Combed bags/day', value: '100'),
                    ResultTile(label: 'Carded bags/day', value: '0'),
                    ResultTile(
                        label: 'Total bags/day', value: '100', highlight: true),
                    ResultTile(label: 'Total frames', value: '10'),
                    ResultTile(label: 'Total spindles', value: '18240'),
                    ResultTile(label: 'Winder spindles needed', value: '400'),
                    ResultTile(label: 'Average count', value: '40'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '2. Machines available (fleet inputs)',
            child: Column(
              children: [
                StyledTextField(
                    controller: _fleetControllers['Autocone spindles'],
                    label: 'Autocone spindles',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Ring spindles'],
                    label: 'Ring spindles',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Simplex flyers'],
                    label: 'Simplex flyers',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Drawing finisher'],
                    label: 'Drawing finisher',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Combers'],
                    label: 'Combers',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Lap former'],
                    label: 'Lap former',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Breakers'],
                    label: 'Breakers',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Cards'],
                    label: 'Cards',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                StyledTextField(
                    controller: _fleetControllers['Blow room lines'],
                    label: 'Blow room lines',
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InputCard(
            title: '3. Balanced plan by department',
            child: ResponsiveTable(
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
                rows: _balancedPlanRows
                    .map((row) => DataRow(
                          cells: row
                              .asMap()
                              .entries
                              .map((entry) => DataCell(Text(
                                    entry.value,
                                    style: entry.key == row.length - 1
                                        ? const TextStyle(color: Colors.green)
                                        : null,
                                  )))
                              .toList(),
                        ))
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const InputCard(
            title: '4. Count-wise spin plan summary',
            child: Center(
                child: Text('Summary table would go here',
                    style: TextStyle(color: SpinColors.bodyText))),
          ),
        ],
      ),
    );
  }
}
