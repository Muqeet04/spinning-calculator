import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/pdf_report_helpers.dart';
import '../widgets/responsive_layout.dart';

class CottonRow {
  String name;
  double blend1Percent;
  double yield1Percent;
  double moistPercent;
  double blend2Percent;
  double yield2Percent;

  CottonRow({
    required this.name,
    this.blend1Percent = 0.0,
    this.yield1Percent = 100.0,
    this.moistPercent = 8.5,
    this.blend2Percent = 0.0,
    this.yield2Percent = 100.0,
  });
}

class BlowRoomWasteScreen extends StatefulWidget {
  const BlowRoomWasteScreen({super.key});

  @override
  State<BlowRoomWasteScreen> createState() => _BlowRoomWasteScreenState();
}

class _BlowRoomWasteScreenState extends State<BlowRoomWasteScreen> {
  final List<CottonRow> _cottonRows = [
    CottonRow(name: 'USA', blend1Percent: 100, yield1Percent: 92),
    CottonRow(name: 'PAK', yield1Percent: 90),
    CottonRow(name: 'Greek', yield1Percent: 91),
    CottonRow(name: 'Tencel', yield1Percent: 98),
    CottonRow(name: 'Ivory', yield1Percent: 88),
    CottonRow(name: 'Brazilian', yield1Percent: 91),
    CottonRow(name: 'Spanish', yield1Percent: 90),
  ];

  double _blend1Wt = 100.0;
  double _blend2Wt = 0.0;

  double _rovingPercent = 0.0;
  double _sweepingPercent = 0.0;
  double _hardWastePercent = 0.0;
  double _acFanPercent = 0.0;
  double _wtLossPercent = 0.0;

  double _blowFeedKg = 1000.0;
  double _blowWasteKg = 80.0;

  double _cardFeedKg = 920.0;
  double _cardWasteKg = 45.0;

  double get _totalBlend1 =>
      _cottonRows.fold(0.0, (sum, row) => sum + row.blend1Percent);
  double get _totalBlend2 =>
      _cottonRows.fold(0.0, (sum, row) => sum + row.blend2Percent);

  double get _overallYield1 {
    if (_totalBlend1 == 0) return 0;
    return _cottonRows.fold(0.0,
        (sum, row) => sum + (row.yield1Percent * (row.blend1Percent / 100)));
  }

  double get _overallYield2 {
    if (_totalBlend2 == 0) return 0;
    return _cottonRows.fold(0.0,
        (sum, row) => sum + (row.yield2Percent * (row.blend2Percent / 100)));
  }

  double get _overallYield {
    double totalWt = _blend1Wt + _blend2Wt;
    if (totalWt == 0) return 0;
    return ((_overallYield1 * _blend1Wt) + (_overallYield2 * _blend2Wt)) /
        totalWt;
  }

  double get _avgMoisture {
    double totalBlend = _totalBlend1;
    if (totalBlend == 0) return 0;
    return _cottonRows.fold(0.0,
        (sum, row) => sum + (row.moistPercent * (row.blend1Percent / 100)));
  }

  double get _nonUseableTotal =>
      _rovingPercent + _sweepingPercent + _hardWastePercent + _acFanPercent;
  double get _grandTotal => _nonUseableTotal + _wtLossPercent;

  double get _brCardWastePercent {
    double val = 100.0 - _overallYield - _grandTotal;
    if (val == 100.0 && _overallYield == 0 && _grandTotal == 0) return 100.0;
    return val;
  }

  double get _blowWastePercent =>
      _blowFeedKg > 0 ? (_blowWasteKg / _blowFeedKg) * 100 : 0.0;
  double get _blowYieldPercent => 100.0 - _blowWastePercent;
  double get _blowOutputKg => _blowFeedKg - _blowWasteKg;

  double get _cardWastePercent =>
      _cardFeedKg > 0 ? (_cardWasteKg / _cardFeedKg) * 100 : 0.0;
  double get _cardYieldPercent => 100.0 - _cardWastePercent;
  double get _cardOutputKg => _cardFeedKg - _cardWasteKg;

  double get _combinedYieldPercent =>
      (_blowYieldPercent / 100) * (_cardYieldPercent / 100) * 100;
  double get _combinedWastePercent => 100.0 - _combinedYieldPercent;

  void _addCottonRow() {
    setState(() {
      _cottonRows.add(CottonRow(name: 'New Cotton'));
    });
  }

  void _removeCottonRow(int index) {
    setState(() {
      _cottonRows.removeAt(index);
    });
  }

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final widgets = <pw.Widget>[];

    // Cotton Blend Table
    widgets.add(
        PdfReportHelpers.sectionTitle('1. Cotton Mixing, Yield & Moisture'));
    final blendTableRows = _cottonRows.map((r) {
      return [
        r.name,
        r.blend1Percent > 0 ? '${r.blend1Percent.toStringAsFixed(1)}%' : '-',
        '${r.yield1Percent.toStringAsFixed(1)}%',
        '${r.moistPercent.toStringAsFixed(1)}%',
        r.blend2Percent > 0 ? '${r.blend2Percent.toStringAsFixed(1)}%' : '-',
        '${r.yield2Percent.toStringAsFixed(1)}%',
      ];
    }).toList();
    blendTableRows.add([
      'Total',
      '${_totalBlend1.toStringAsFixed(2)}%',
      '',
      '',
      '${_totalBlend2.toStringAsFixed(2)}%',
      '',
    ]);

    widgets.add(
      PdfReportHelpers.dataTable(
        headers: [
          'Cotton',
          'Blend 1 %',
          'Yield 1 %',
          'Moist %',
          'Blend 2 %',
          'Yield 2 %'
        ],
        rows: blendTableRows,
        flexWidths: [2.5, 2, 2, 2, 2, 2],
      ),
    );
    widgets.add(pw.SizedBox(height: 8));

    if ((_totalBlend1 - 100).abs() > 0.01) {
      widgets.add(pw.Text(
        'Blend1 % must total 100% (currently ${_totalBlend1.toStringAsFixed(2)}%)',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
      ));
    }
    if (_totalBlend2 > 0 && (_totalBlend2 - 100).abs() > 0.01) {
      widgets.add(pw.Text(
        'Blend2 % must total 100% (currently ${_totalBlend2.toStringAsFixed(2)}%)',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
      ));
    }

    widgets.add(
      pw.Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          PdfReportHelpers.summaryCard(
              'Blend 1 Wt %', '${_blend1Wt.toStringAsFixed(1)}%'),
          PdfReportHelpers.summaryCard(
              'Blend 2 Wt %', '${_blend2Wt.toStringAsFixed(1)}%'),
          PdfReportHelpers.summaryCard(
              'Overall Yield %', '${_overallYield.toStringAsFixed(2)}%',
              highlight: true),
          PdfReportHelpers.summaryCard(
              'Avg Moisture %', '${_avgMoisture.toStringAsFixed(2)}%'),
        ],
      ),
    );
    widgets.add(pw.SizedBox(height: 12));

    // Non-useable wastages
    widgets.add(PdfReportHelpers.sectionTitle(
        '2. Non-useable Wastages & Process Loss'));
    widgets.add(
      PdfReportHelpers.keyValGrid({
        'Roving Waste %': '${_rovingPercent.toStringAsFixed(2)}%',
        'Sweeping Waste %': '${_sweepingPercent.toStringAsFixed(2)}%',
        'Hard Waste %': '${_hardWastePercent.toStringAsFixed(2)}%',
        'AC Fan Waste %': '${_acFanPercent.toStringAsFixed(2)}%',
        'Weight / Moisture Loss %': '${_wtLossPercent.toStringAsFixed(2)}%',
        'Non-useable Total %': '${_nonUseableTotal.toStringAsFixed(2)}%',
        'Grand Total Waste %': '${_grandTotal.toStringAsFixed(2)}%',
        'B.Room + Card Waste %': '${_brCardWastePercent.toStringAsFixed(2)}%',
      }),
    );
    widgets.add(pw.SizedBox(height: 12));

    // Blow Room & Card measured kg
    widgets.add(PdfReportHelpers.sectionTitle(
        '3. Blow Room & Carding Output (Kg Basis)'));
    if (_blowWasteKg > _blowFeedKg) {
      widgets.add(pw.Text(
        'Blow room: Enter valid values (waste cannot exceed feed).',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
      ));
    }
    if (_cardWasteKg > _cardFeedKg) {
      widgets.add(pw.Text(
        'Card: Enter valid values (waste cannot exceed feed).',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
      ));
    }
    widgets.add(
      PdfReportHelpers.dataTable(
        headers: [
          'Process Stage',
          'Material Fed (kg)',
          'Waste (kg)',
          'Waste %',
          'Yield %',
          'Net Output (kg)'
        ],
        rows: [
          [
            'Blow Room',
            _blowFeedKg.toStringAsFixed(1),
            _blowWasteKg.toStringAsFixed(1),
            '${_blowWastePercent.toStringAsFixed(2)}%',
            '${_blowYieldPercent.toStringAsFixed(2)}%',
            _blowOutputKg.toStringAsFixed(1),
          ],
          [
            'Carding',
            _cardFeedKg.toStringAsFixed(1),
            _cardWasteKg.toStringAsFixed(1),
            '${_cardWastePercent.toStringAsFixed(2)}%',
            '${_cardYieldPercent.toStringAsFixed(2)}%',
            _cardOutputKg.toStringAsFixed(1),
          ],
        ],
        flexWidths: [3, 3, 2.5, 2.5, 2.5, 3],
      ),
    );
    widgets.add(pw.SizedBox(height: 10));

    // Combined
    widgets.add(pw.NewPage(freeSpace: 80));
    widgets
        .add(PdfReportHelpers.sectionTitle('4. Combined Process Performance'));
    widgets.add(
      pw.Row(
        children: [
          pw.Expanded(
            child: PdfReportHelpers.summaryCard('Combined Yield (Blow -> Card)',
                '${_combinedYieldPercent.toStringAsFixed(2)}%',
                highlight: true),
          ),
          pw.Expanded(
            child: PdfReportHelpers.summaryCard('Combined Process Waste %',
                '${_combinedWastePercent.toStringAsFixed(2)}%'),
          ),
        ],
      ),
    );

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    bool blend1Error = (_totalBlend1 - 100).abs() > 0.01;
    bool blend2Error = _totalBlend2 > 0 && (_totalBlend2 - 100).abs() > 0.01;
    bool blowError = _blowWasteKg > _blowFeedKg;
    bool cardError = _cardWasteKg > _cardFeedKg;

    return PageScaffold(
      title: 'Blow room & card waste calculator',
      subtitle: 'Waste %, lap/sliver output and combined process loss',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputCard(
            title: 'Cotton mixing, yield & waste',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveRow(
                  children: [
                    Expanded(
                      child: StyledTextField(
                        label: 'Blend1 %age Wt.',
                        initialValue: _blend1Wt.toString(),
                        onChanged: (val) => setState(
                            () => _blend1Wt = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StyledTextField(
                        label: 'Blend2 %age Wt.',
                        initialValue: _blend2Wt.toString(),
                        onChanged: (val) => setState(
                            () => _blend2Wt = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ResponsiveTable(
                  child: DataTable(
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Cotton')),
                      DataColumn(label: Text('Blend1 %')),
                      DataColumn(label: Text('Yield %')),
                      DataColumn(label: Text('Moist. %')),
                      DataColumn(label: Text('Blend2 %')),
                      DataColumn(label: Text('Yield %')),
                      DataColumn(label: Text('')),
                    ],
                    rows: [
                      ..._cottonRows.asMap().entries.map((entry) {
                        int i = entry.key;
                        CottonRow row = entry.value;
                        return DataRow(cells: [
                          DataCell(Text(row.name)),
                          DataCell(SizedBox(
                            width: 70,
                            child: TextField(
                              controller: TextEditingController(
                                  text: row.blend1Percent.toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => row
                                  .blend1Percent = double.tryParse(val) ?? 0.0),
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 70,
                            child: TextField(
                              controller: TextEditingController(
                                  text: row.yield1Percent.toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => row
                                  .yield1Percent = double.tryParse(val) ?? 0.0),
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 70,
                            child: TextField(
                              controller: TextEditingController(
                                  text: row.moistPercent.toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => row
                                  .moistPercent = double.tryParse(val) ?? 0.0),
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 70,
                            child: TextField(
                              controller: TextEditingController(
                                  text: row.blend2Percent.toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => row
                                  .blend2Percent = double.tryParse(val) ?? 0.0),
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 70,
                            child: TextField(
                              controller: TextEditingController(
                                  text: row.yield2Percent.toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (val) => setState(() => row
                                  .yield2Percent = double.tryParse(val) ?? 0.0),
                            ),
                          )),
                          DataCell(IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeCottonRow(i),
                          )),
                        ]);
                      }),
                      DataRow(cells: [
                        const DataCell(Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(_totalBlend1.toStringAsFixed(2),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blend1Error ? Colors.red : null))),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                        DataCell(Text(_totalBlend2.toStringAsFixed(2),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blend2Error ? Colors.red : null))),
                        const DataCell(Text('')),
                        const DataCell(Text('')),
                      ]),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCottonRow,
                  icon: const Icon(Icons.add),
                  label: const Text('Add cotton'),
                ),
                if (blend1Error)
                  Text(
                      'Blend1 % must total 100% (currently ${_totalBlend1.toStringAsFixed(2)}%)',
                      style: const TextStyle(color: Colors.red)),
                if (blend2Error)
                  Text(
                      'Blend2 % must total 100% (currently ${_totalBlend2.toStringAsFixed(2)}%)',
                      style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    ResultTile(
                        label: 'Overall yield %',
                        value: '${_overallYield.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Avg moisture %',
                        value: '${_avgMoisture.toStringAsFixed(2)}%'),
                  ],
                ),
              ],
            ),
          ),
          InputCard(
            title: 'Non-useable wastages (%)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveResults(
                  children: [
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Roving %',
                            initialValue: _rovingPercent.toString(),
                            onChanged: (val) => setState(() =>
                                _rovingPercent = double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Sweeping %',
                            initialValue: _sweepingPercent.toString(),
                            onChanged: (val) => setState(() =>
                                _sweepingPercent =
                                    double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Hard waste %',
                            initialValue: _hardWastePercent.toString(),
                            onChanged: (val) => setState(() =>
                                _hardWastePercent =
                                    double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'AC fan %',
                            initialValue: _acFanPercent.toString(),
                            onChanged: (val) => setState(() =>
                                _acFanPercent = double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Wt. loss %',
                            initialValue: _wtLossPercent.toString(),
                            onChanged: (val) => setState(() =>
                                _wtLossPercent = double.tryParse(val) ?? 0.0))),
                  ],
                ),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    ResultTile(
                        label: 'Non-useable total',
                        value: '${_nonUseableTotal.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Grand total',
                        value: '${_grandTotal.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'B.Room+Card waste %',
                        value: '${_brCardWastePercent.toStringAsFixed(2)}%',
                        highlight: true),
                  ],
                ),
              ],
            ),
          ),
          InputCard(
            title: 'Blow room (measured, kg basis)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveResults(
                  children: [
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Mixing fed (kg)',
                            initialValue: _blowFeedKg.toString(),
                            onChanged: (val) => setState(() =>
                                _blowFeedKg = double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Total waste (kg)',
                            initialValue: _blowWasteKg.toString(),
                            onChanged: (val) => setState(() =>
                                _blowWasteKg = double.tryParse(val) ?? 0.0))),
                  ],
                ),
                if (blowError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Enter valid values (waste cannot exceed feed).',
                        style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    ResultTile(
                        label: 'Waste %',
                        value: '${_blowWastePercent.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Yield %',
                        value: '${_blowYieldPercent.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Output (kg)',
                        value: _blowOutputKg.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          InputCard(
            title: 'Card (measured, kg basis)',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _cardFeedKg = _blowOutputKg;
                    });
                  },
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Use blow room output as feed'),
                ),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Material fed (kg)',
                            initialValue: _cardFeedKg.toString(),
                            key: ValueKey('card_feed_$_cardFeedKg'),
                            onChanged: (val) => setState(() =>
                                _cardFeedKg = double.tryParse(val) ?? 0.0))),
                    SizedBox(
                        width: 150,
                        child: StyledTextField(
                            label: 'Total waste (kg)',
                            initialValue: _cardWasteKg.toString(),
                            onChanged: (val) => setState(() =>
                                _cardWasteKg = double.tryParse(val) ?? 0.0))),
                  ],
                ),
                if (cardError)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                        'Enter valid values (waste cannot exceed feed).',
                        style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                ResponsiveResults(
                  children: [
                    ResultTile(
                        label: 'Waste %',
                        value: '${_cardWastePercent.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Yield %',
                        value: '${_cardYieldPercent.toStringAsFixed(2)}%'),
                    ResultTile(
                        label: 'Sliver out (kg)',
                        value: _cardOutputKg.toStringAsFixed(2)),
                  ],
                ),
              ],
            ),
          ),
          InputCard(
            title: 'Combined (blow room → card)',
            child: ResponsiveResults(
              children: [
                ResultTile(
                    label: 'Combined yield %',
                    value: '${_combinedYieldPercent.toStringAsFixed(2)}%'),
                ResultTile(
                    label: 'Combined waste %',
                    value: '${_combinedWastePercent.toStringAsFixed(2)}%',
                    highlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
