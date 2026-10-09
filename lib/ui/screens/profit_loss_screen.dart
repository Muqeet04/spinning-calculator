import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import '../widgets/page_scaffold.dart';
import '../widgets/input_card.dart';
import '../widgets/result_tile.dart';
import '../widgets/styled_text_field.dart';
import '../widgets/pdf_report_helpers.dart';
import '../../app/theme.dart';
import '../widgets/responsive_layout.dart';

class CottonRow {
  String name;
  double rateKg;
  double cdYield;
  double cmYield;
  double percentage;

  CottonRow(
      this.name, this.rateKg, this.cdYield, this.cmYield, this.percentage);
}

class CountRow {
  String count;
  String blend;
  String channel;
  double ops;
  int frames;
  int spindlesPerFrame;
  double saleLb;

  CountRow(this.count, this.blend, this.channel, this.ops, this.frames,
      this.spindlesPerFrame, this.saleLb);
}

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  // Section 1
  double maundFactor = 37.3242;
  List<CottonRow> cottons = [
    CottonRow('Pak', 0, 88, 70, 0),
    CottonRow('Usa', 0, 90, 72, 0),
    CottonRow('Greek', 0, 89, 71, 0),
    CottonRow('Ivory', 0, 87, 69, 0),
    CottonRow('Brazilian', 0, 89, 71, 0),
    CottonRow('Spanish', 0, 88, 70, 0),
  ];

  // Section 2
  double noilPriceKg = 0;
  int workingDays = 26;
  double exportPackingRateLb = 0;
  double localPackingRateLb = 0;

  // Section 3
  int shiftsPerDay = 3;
  double spindleCostPerShift = 15.5;

  List<CountRow> counts = [
    CountRow('40/1 Combed', 'Combed', 'Export', 6.02, 10, 1824, 0),
    CountRow('30/1 Carded', 'Carded', 'Local', 8.50, 10, 1824, 0),
  ];

  Future<List<pw.Widget>> _buildPdfReport(pw.Context context) async {
    final widgets = <pw.Widget>[
      PdfReportHelpers.sectionTitle('1. Raw Material Cost & Blend Matrix'),
      PdfReportHelpers.keyValGrid({
        'Kg per maund': maundFactor.toStringAsFixed(4),
        'Noil price / kg': noilPriceKg.toStringAsFixed(2),
        'Working days / month': '$workingDays',
        'Export packing rate / lb': exportPackingRateLb.toStringAsFixed(2),
        'Local packing rate / lb': localPackingRateLb.toStringAsFixed(2),
        'Shifts / day': '$shiftsPerDay',
        'Spindle cost / spindle / shift':
            spindleCostPerShift.toStringAsFixed(2),
      }),
      pw.SizedBox(height: 8),
    ];

    final totalPct = cottons.fold(0.0, (sum, c) => sum + c.percentage);
    double avgRateKg = 0;
    double avgCmYield = 0;
    double avgComberNoil = 0;
    double avgCostLbCd = 0;
    double avgCostLbCm = 0;
    final cottonRowsPdf = <List<String>>[];
    for (final c in cottons) {
      final weight = c.percentage / 100;
      final costCd =
          c.cdYield > 0 ? (c.rateKg / 2.20462) / (c.cdYield / 100) : 0.0;
      final costCm =
          c.cmYield > 0 ? (c.rateKg / 2.20462) / (c.cmYield / 100) : 0.0;
      final noilPct = (c.cdYield - c.cmYield) * weight;
      if (totalPct > 0) {
        avgRateKg += c.rateKg * weight;
        avgCmYield += c.cmYield * weight;
        avgComberNoil += noilPct;
        avgCostLbCd += costCd * weight;
        avgCostLbCm += costCm * weight;
      }
      cottonRowsPdf.add([
        c.name,
        c.rateKg.toStringAsFixed(2),
        (c.rateKg * maundFactor).toStringAsFixed(2),
        c.cdYield.toStringAsFixed(2),
        c.cmYield.toStringAsFixed(2),
        noilPct.toStringAsFixed(2),
        costCd.toStringAsFixed(2),
        costCm.toStringAsFixed(2),
        c.percentage.toStringAsFixed(2),
      ]);
    }
    cottonRowsPdf.add([
      'Avg/Total',
      avgRateKg.toStringAsFixed(2),
      (avgRateKg * maundFactor).toStringAsFixed(2),
      '-',
      '-',
      avgComberNoil.toStringAsFixed(2),
      avgCostLbCd.toStringAsFixed(2),
      avgCostLbCm.toStringAsFixed(2),
      totalPct.toStringAsFixed(2),
    ]);
    if ((totalPct - 100).abs() > 0.01) {
      widgets.add(pw.Text(
        'Blend percentages do not add up to 100 (currently ${totalPct.toStringAsFixed(2)}%).',
        style: const pw.TextStyle(fontSize: 9),
      ));
      widgets.add(pw.SizedBox(height: 6));
    }
    widgets.add(PdfReportHelpers.dataTable(
      headers: [
        'Cotton',
        'Rate/Kg',
        'Rate/Maund',
        'CD %',
        'CM %',
        'Noil %',
        'Cost/Lb CD',
        'Cost/Lb CM',
        'Blend %'
      ],
      rows: cottonRowsPdf,
      flexWidths: [2, 1.8, 2.2, 1.5, 1.5, 1.5, 2, 2, 1.5],
    ));

    final noilPriceLb = noilPriceKg / 2.20462;
    final noilDeductionLb = noilPriceLb * (avgComberNoil / 100);
    final netCombedCostLb = avgCostLbCm - noilDeductionLb;
    widgets.add(PdfReportHelpers.sectionTitle(
        '2. Noil Deduction & Net Raw Material Cost'));
    widgets.add(PdfReportHelpers.keyValGrid({
      'Blend avg rate / lb': (avgRateKg / 2.20462).toStringAsFixed(4),
      'Avg CM yield (combed)': '${avgCmYield.toStringAsFixed(2)}%',
      'Avg comber noil (blend)': '${avgComberNoil.toStringAsFixed(2)}%',
      'Noil price / lb': noilPriceLb.toStringAsFixed(4),
      'Noil deduction / lb of cotton': noilDeductionLb.toStringAsFixed(4),
      'Net Carded cost / lb': avgCostLbCd.toStringAsFixed(4),
      'Net Combed cost / lb': netCombedCostLb.toStringAsFixed(4),
    }));

    final setupRows = <List<String>>[];
    final makingRows = <List<String>>[];
    final costRows = <List<String>>[];
    final profitRows = <List<String>>[];
    double profitPerDay = 0;
    for (final c in counts) {
      final totalSpindles = c.frames * c.spindlesPerFrame;
      final lbsFrameDay = c.spindlesPerFrame * (c.ops / 16) * shiftsPerDay;
      final lbsDay = c.frames * lbsFrameDay;
      final makingCostDay = spindleCostPerShift * totalSpindles * shiftsPerDay;
      final makingLb = lbsDay > 0 ? makingCostDay / lbsDay : 0.0;
      final rawMatLb = c.blend == 'Combed' ? netCombedCostLb : avgCostLbCd;
      final totalMakRaw = makingLb + rawMatLb;
      final packingLb =
          c.channel == 'Export' ? exportPackingRateLb : localPackingRateLb;
      final grandTotal = totalMakRaw + packingLb;
      final diffLb = c.saleLb - grandTotal;
      final diffTotal = diffLb * lbsDay;
      profitPerDay += diffTotal;
      setupRows.add([
        c.count,
        c.blend,
        c.channel,
        c.ops.toStringAsFixed(2),
        '${c.frames}',
        '${c.spindlesPerFrame}',
        '$totalSpindles',
      ]);
      makingRows.add([
        c.count,
        lbsFrameDay.toStringAsFixed(2),
        lbsDay.toStringAsFixed(2),
        makingCostDay.toStringAsFixed(2),
        makingLb.toStringAsFixed(4),
      ]);
      costRows.add([
        c.count,
        c.channel,
        makingLb.toStringAsFixed(4),
        rawMatLb.toStringAsFixed(4),
        totalMakRaw.toStringAsFixed(4),
        packingLb.toStringAsFixed(4),
        grandTotal.toStringAsFixed(4),
      ]);
      profitRows.add([
        c.count,
        lbsDay.toStringAsFixed(2),
        grandTotal.toStringAsFixed(4),
        c.saleLb.toStringAsFixed(2),
        diffLb.toStringAsFixed(4),
        diffTotal.toStringAsFixed(2),
      ]);
    }
    widgets.addAll([
      PdfReportHelpers.sectionTitle('3. Making Charges & Spindle Economics'),
      PdfReportHelpers.dataTable(
        headers: [
          'Count',
          'Blend',
          'Channel',
          'OPS',
          'Frames',
          'Spindles/Frame',
          'Total Spindles'
        ],
        rows: setupRows,
        flexWidths: [2.5, 1.8, 1.8, 1.3, 1.2, 2, 2],
      ),
      pw.SizedBox(height: 8),
      pw.NewPage(freeSpace: 80),
      PdfReportHelpers.dataTable(
        headers: [
          'Count',
          'Lbs/Frame/Day',
          'Lbs/Day',
          'Making Cost/Day',
          'Making/Lb'
        ],
        rows: makingRows,
        flexWidths: [2.5, 2.2, 2, 2.5, 2],
      ),
      PdfReportHelpers.sectionTitle('4. Cost Per Lb & Profit / Loss Per Count'),
      PdfReportHelpers.dataTable(
        headers: [
          'Count',
          'Channel',
          'Making/Lb',
          'Raw Material/Lb',
          'Total (Making+Raw)',
          'Packing/Lb',
          'Grand Total Cost/Lb'
        ],
        rows: costRows,
        flexWidths: [2.5, 1.5, 1.8, 2, 2.2, 1.8, 2.2],
      ),
      pw.SizedBox(height: 8),
      PdfReportHelpers.dataTable(
        headers: [
          'Count',
          'Lbs/Day',
          'Grand Total Cost/Lb',
          'Sale/Lb',
          'Diff/Lb',
          'Diff.Total'
        ],
        rows: profitRows,
        flexWidths: [2.5, 2, 2.5, 1.8, 1.8, 2.2],
      ),
      PdfReportHelpers.sectionTitle('5. Mill Profit / Loss Summary'),
      pw.Row(children: [
        pw.Expanded(
            child: PdfReportHelpers.summaryCard(
          'Profit / Loss Per Day',
          profitPerDay.toStringAsFixed(2),
          highlight: profitPerDay >= 0,
        )),
        pw.Expanded(
            child: PdfReportHelpers.summaryCard(
          'Profit / Loss Per Month',
          (profitPerDay * workingDays).toStringAsFixed(2),
          highlight: profitPerDay >= 0,
        )),
        pw.Expanded(
            child: PdfReportHelpers.summaryCard(
          'Profit / Loss Per Year',
          (profitPerDay * workingDays * 12).toStringAsFixed(2),
          highlight: profitPerDay >= 0,
        )),
      ]),
    ]);
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Cotton blend costing & mill profit / loss',
      subtitle:
          'Raw-material blend cost, making charges and profit-loss per day, month and year.',
      onGeneratePdfReport: _buildPdfReport,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection1(),
          const SizedBox(height: 24),
          _buildSection2(),
          const SizedBox(height: 24),
          _buildSection3(),
          const SizedBox(height: 24),
          _buildSection4(),
          const SizedBox(height: 24),
          _buildSection5(),
        ],
      ),
    );
  }

  Widget _buildSection1() {
    double totalPct = cottons.fold(0, (sum, c) => sum + c.percentage);
    bool pctWarning = (totalPct - 100).abs() > 0.01;

    double avgRateKg = 0;
    double avgCostLbCd = 0;
    double avgCostLbCm = 0;
    double avgComberNoil = 0;

    if (totalPct > 0) {
      for (var c in cottons) {
        double w = c.percentage / 100;
        avgRateKg += c.rateKg * w;
        double costCd =
            (c.cdYield > 0) ? (c.rateKg / 2.20462) / (c.cdYield / 100) : 0;
        double costCm =
            (c.cmYield > 0) ? (c.rateKg / 2.20462) / (c.cmYield / 100) : 0;
        avgCostLbCd += costCd * w;
        avgCostLbCm += costCm * w;
        avgComberNoil += (c.cdYield - c.cmYield) * w;
      }
    }

    return InputCard(
      title: '1. Raw material cost',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            children: [
              Expanded(
                child: StyledTextField(
                  label: '1 maund = how many kg',
                  isNumber: true,
                  controller: TextEditingController(
                      text: maundFactor.toStringAsFixed(4)),
                  onChanged: (v) => setState(
                      () => maundFactor = double.tryParse(v) ?? 37.3242),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
          if (pctWarning) ...[
            const SizedBox(height: 16),
            Text(
              '%age does not add up to 100 (currently ${totalPct.toStringAsFixed(2)}%)',
              style: const TextStyle(
                  color: SpinColors.errorRed, fontWeight: FontWeight.bold),
            ),
          ],
          const SizedBox(height: 16),
          ResponsiveTable(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Cotton')),
                DataColumn(label: Text('Rate/Kg')),
                DataColumn(label: Text('Rate/Maund')),
                DataColumn(label: Text('CD-Yield %')),
                DataColumn(label: Text('CM-Yield %')),
                DataColumn(label: Text('Comber Noil %')),
                DataColumn(label: Text('Cost/Lb CD')),
                DataColumn(label: Text('Cost/Lb CM')),
                DataColumn(label: Text('%age')),
                DataColumn(label: Text('Actions')),
              ],
              rows: [
                ...cottons.map((c) {
                  double rateMaund = c.rateKg * maundFactor;
                  double costCd = c.cdYield > 0
                      ? (c.rateKg / 2.20462) / (c.cdYield / 100)
                      : 0;
                  double costCm = c.cmYield > 0
                      ? (c.rateKg / 2.20462) / (c.cmYield / 100)
                      : 0;
                  double comberNoil =
                      (c.cdYield - c.cmYield) * (c.percentage / 100);

                  return DataRow(cells: [
                    DataCell(TextFormField(
                      initialValue: c.name,
                      onChanged: (v) => setState(() => c.name = v),
                    )),
                    DataCell(TextFormField(
                      initialValue: c.rateKg.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) =>
                          setState(() => c.rateKg = double.tryParse(v) ?? 0),
                    )),
                    DataCell(Text(rateMaund.toStringAsFixed(2))),
                    DataCell(TextFormField(
                      initialValue: c.cdYield.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) =>
                          setState(() => c.cdYield = double.tryParse(v) ?? 0),
                    )),
                    DataCell(TextFormField(
                      initialValue: c.cmYield.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) =>
                          setState(() => c.cmYield = double.tryParse(v) ?? 0),
                    )),
                    DataCell(Text(comberNoil.toStringAsFixed(2))),
                    DataCell(Text(costCd.toStringAsFixed(2))),
                    DataCell(Text(costCm.toStringAsFixed(2))),
                    DataCell(TextFormField(
                      initialValue: c.percentage.toStringAsFixed(2),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(
                          () => c.percentage = double.tryParse(v) ?? 0),
                    )),
                    DataCell(IconButton(
                      icon:
                          const Icon(Icons.delete, color: SpinColors.errorRed),
                      onPressed: () => setState(() => cottons.remove(c)),
                    )),
                  ]);
                }),
                DataRow(cells: [
                  const DataCell(Text('Avg/Total',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(avgRateKg.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text((avgRateKg * maundFactor).toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  const DataCell(Text('-')),
                  const DataCell(Text('-')),
                  DataCell(Text(avgComberNoil.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(avgCostLbCd.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(avgCostLbCm.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(totalPct.toStringAsFixed(2),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
                  const DataCell(Text('')),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add cotton'),
            onPressed: () =>
                setState(() => cottons.add(CottonRow('New', 0, 0, 0, 0))),
          ),
        ],
      ),
    );
  }

  Widget _buildSection2() {
    double totalPct = cottons.fold(0, (sum, c) => sum + c.percentage);
    double avgRateKg = 0;
    double avgCmYield = 0;
    double avgComberNoil = 0;
    double avgCostLbCd = 0;
    double avgCostLbCm = 0;

    if (totalPct > 0) {
      for (var c in cottons) {
        double w = c.percentage / 100;
        avgRateKg += c.rateKg * w;
        avgCmYield += c.cmYield * w;
        avgComberNoil += (c.cdYield - c.cmYield) * w;
        double costCd =
            (c.cdYield > 0) ? (c.rateKg / 2.20462) / (c.cdYield / 100) : 0;
        double costCm =
            (c.cmYield > 0) ? (c.rateKg / 2.20462) / (c.cmYield / 100) : 0;
        avgCostLbCd += costCd * w;
        avgCostLbCm += costCm * w;
      }
    }

    double blendAvgRateLb = avgRateKg / 2.20462;
    double noilPriceLb = noilPriceKg / 2.20462;
    double noilDeductionLb = noilPriceLb * (avgComberNoil / 100);
    double netCombedCostLb = avgCostLbCm - noilDeductionLb;

    return InputCard(
      title: '2. Noil deduction & net raw-material cost',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            children: [
              Expanded(
                  child: StyledTextField(
                label: 'Noil price /kg',
                isNumber: true,
                controller:
                    TextEditingController(text: noilPriceKg.toStringAsFixed(2)),
                onChanged: (v) =>
                    setState(() => noilPriceKg = double.tryParse(v) ?? 0),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: StyledTextField(
                label: 'Working days per month',
                isNumber: true,
                controller: TextEditingController(text: workingDays.toString()),
                onChanged: (v) =>
                    setState(() => workingDays = int.tryParse(v) ?? 26),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: StyledTextField(
                label: 'Export packing rate /lb',
                isNumber: true,
                controller: TextEditingController(
                    text: exportPackingRateLb.toStringAsFixed(2)),
                onChanged: (v) => setState(
                    () => exportPackingRateLb = double.tryParse(v) ?? 0),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: StyledTextField(
                label: 'Local packing rate /lb',
                isNumber: true,
                controller: TextEditingController(
                    text: localPackingRateLb.toStringAsFixed(2)),
                onChanged: (v) => setState(
                    () => localPackingRateLb = double.tryParse(v) ?? 0),
              )),
            ],
          ),
          const SizedBox(height: 24),
          ResponsiveResults(
            children: [
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Blend avg rate/lb',
                      value: blendAvgRateLb.toStringAsFixed(4))),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Avg CM yield (combed)',
                      value: '${avgCmYield.toStringAsFixed(2)}%')),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Avg comber noil % (blend)',
                      value: '${avgComberNoil.toStringAsFixed(2)}%')),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Noil price /lb',
                      value: noilPriceLb.toStringAsFixed(4))),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Noil deduction /lb of cotton',
                      value: noilDeductionLb.toStringAsFixed(4))),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Net Carded cost /lb',
                      value: avgCostLbCd.toStringAsFixed(4))),
              SizedBox(
                  width: 200,
                  child: ResultTile(
                      label: 'Net Combed cost /lb',
                      value: netCombedCostLb.toStringAsFixed(4))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection3() {
    return InputCard(
      title: '3. Making charges (from spindle cost per shift)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRow(
            children: [
              Expanded(
                  child: StyledTextField(
                label: 'Shifts per day',
                isNumber: true,
                controller:
                    TextEditingController(text: shiftsPerDay.toString()),
                onChanged: (v) =>
                    setState(() => shiftsPerDay = int.tryParse(v) ?? 3),
              )),
              const SizedBox(width: 16),
              Expanded(
                  child: StyledTextField(
                label: 'Spindle cost /spindle/shift',
                isNumber: true,
                controller: TextEditingController(
                    text: spindleCostPerShift.toStringAsFixed(2)),
                onChanged: (v) => setState(
                    () => spindleCostPerShift = double.tryParse(v) ?? 15.5),
              )),
              const Spacer(flex: 2),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveTable(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Count')),
                DataColumn(label: Text('Blend')),
                DataColumn(label: Text('Channel')),
                DataColumn(label: Text('O.P.S')),
                DataColumn(label: Text('Frames')),
                DataColumn(label: Text('Spindles/Frame')),
                DataColumn(label: Text('Total Spindles')),
                DataColumn(label: Text('Lbs/Frame/Day')),
                DataColumn(label: Text('Lbs/Day')),
                DataColumn(label: Text('Making Cost/Day')),
                DataColumn(label: Text('Making/Lb')),
                DataColumn(label: Text('Actions')),
              ],
              rows: counts.map((c) {
                int totalSpindles = c.frames * c.spindlesPerFrame;
                double lbsFrameDay =
                    c.spindlesPerFrame * (c.ops / 16) * shiftsPerDay;
                double lbsDay = c.frames * lbsFrameDay;
                double makingCostDay =
                    spindleCostPerShift * totalSpindles * shiftsPerDay;
                double makingLb = lbsDay > 0 ? makingCostDay / lbsDay : 0;

                return DataRow(cells: [
                  DataCell(TextFormField(
                    initialValue: c.count,
                    onChanged: (v) => setState(() => c.count = v),
                  )),
                  DataCell(DropdownButton<String>(
                    value: c.blend,
                    items: const [
                      DropdownMenuItem(value: 'Combed', child: Text('Combed')),
                      DropdownMenuItem(value: 'Carded', child: Text('Carded')),
                    ],
                    onChanged: (v) => setState(() => c.blend = v!),
                  )),
                  DataCell(DropdownButton<String>(
                    value: c.channel,
                    items: const [
                      DropdownMenuItem(value: 'Export', child: Text('Export')),
                      DropdownMenuItem(value: 'Local', child: Text('Local')),
                    ],
                    onChanged: (v) => setState(() => c.channel = v!),
                  )),
                  DataCell(TextFormField(
                    initialValue: c.ops.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        setState(() => c.ops = double.tryParse(v) ?? 0),
                  )),
                  DataCell(TextFormField(
                    initialValue: c.frames.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        setState(() => c.frames = int.tryParse(v) ?? 0),
                  )),
                  DataCell(TextFormField(
                    initialValue: c.spindlesPerFrame.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(
                        () => c.spindlesPerFrame = int.tryParse(v) ?? 0),
                  )),
                  DataCell(Text(totalSpindles.toString())),
                  DataCell(Text(lbsFrameDay.toStringAsFixed(2))),
                  DataCell(Text(lbsDay.toStringAsFixed(2))),
                  DataCell(Text(makingCostDay.toStringAsFixed(2))),
                  DataCell(Text(makingLb.toStringAsFixed(4))),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: SpinColors.errorRed),
                    onPressed: () => setState(() => counts.remove(c)),
                  )),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add count'),
            onPressed: () => setState(() =>
                counts.add(CountRow('New', 'Combed', 'Export', 0, 0, 0, 0))),
          ),
        ],
      ),
    );
  }

  Widget _buildSection4() {
    double totalPct = cottons.fold(0, (sum, c) => sum + c.percentage);
    double avgCostLbCd = 0;
    double avgCostLbCm = 0;
    double avgComberNoil = 0;

    if (totalPct > 0) {
      for (var c in cottons) {
        double w = c.percentage / 100;
        avgComberNoil += (c.cdYield - c.cmYield) * w;
        double costCd =
            (c.cdYield > 0) ? (c.rateKg / 2.20462) / (c.cdYield / 100) : 0;
        double costCm =
            (c.cmYield > 0) ? (c.rateKg / 2.20462) / (c.cmYield / 100) : 0;
        avgCostLbCd += costCd * w;
        avgCostLbCm += costCm * w;
      }
    }

    double noilPriceLb = noilPriceKg / 2.20462;
    double noilDeductionLb = noilPriceLb * (avgComberNoil / 100);
    double netCombedCostLb = avgCostLbCm - noilDeductionLb;

    double totalDiffTotal = 0;

    return InputCard(
      title: '4. Cost per lb & profit/loss per count',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveTable(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Count')),
                DataColumn(label: Text('Channel')),
                DataColumn(label: Text('Lbs/Day')),
                DataColumn(label: Text('Making/Lb')),
                DataColumn(label: Text('Raw Material/Lb')),
                DataColumn(label: Text('Total (Making+Raw)')),
                DataColumn(label: Text('Packing/Lb')),
                DataColumn(label: Text('Grand Total Cost/Lb')),
                DataColumn(label: Text('Sale/Lb')),
                DataColumn(label: Text('Diff/Lb')),
                DataColumn(label: Text('Diff.Total')),
              ],
              rows: counts.map((c) {
                int totalSpindles = c.frames * c.spindlesPerFrame;
                double lbsFrameDay =
                    c.spindlesPerFrame * (c.ops / 16) * shiftsPerDay;
                double lbsDay = c.frames * lbsFrameDay;
                double makingCostDay =
                    spindleCostPerShift * totalSpindles * shiftsPerDay;
                double makingLb = lbsDay > 0 ? makingCostDay / lbsDay : 0;

                double rawMatLb =
                    c.blend == 'Combed' ? netCombedCostLb : avgCostLbCd;
                double totalMakRaw = makingLb + rawMatLb;
                double packingLb = c.channel == 'Export'
                    ? exportPackingRateLb
                    : localPackingRateLb;
                double grandTotal = totalMakRaw + packingLb;

                double diffLb = c.saleLb - grandTotal;
                double diffTotal = diffLb * lbsDay;
                totalDiffTotal += diffTotal;

                return DataRow(cells: [
                  DataCell(Text(c.count)),
                  DataCell(Text(c.channel)),
                  DataCell(Text(lbsDay.toStringAsFixed(2))),
                  DataCell(Text(makingLb.toStringAsFixed(4))),
                  DataCell(Text(rawMatLb.toStringAsFixed(4))),
                  DataCell(Text(totalMakRaw.toStringAsFixed(4))),
                  DataCell(Text(packingLb.toStringAsFixed(4))),
                  DataCell(Text(grandTotal.toStringAsFixed(4))),
                  DataCell(TextFormField(
                    initialValue: c.saleLb.toStringAsFixed(2),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) =>
                        setState(() => c.saleLb = double.tryParse(v) ?? 0),
                  )),
                  DataCell(Text(diffLb.toStringAsFixed(4),
                      style: TextStyle(
                          color: diffLb >= 0
                              ? SpinColors.successGreen
                              : SpinColors.errorRed))),
                  DataCell(Text(diffTotal.toStringAsFixed(2),
                      style: TextStyle(
                          color: diffTotal >= 0
                              ? SpinColors.successGreen
                              : SpinColors.errorRed))),
                ]);
              }).toList()
                ..add(DataRow(cells: [
                  const DataCell(Text('Profit-Loss Per Day',
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  const DataCell(Text('')),
                  DataCell(Text(totalDiffTotal.toStringAsFixed(2),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: totalDiffTotal >= 0
                              ? SpinColors.successGreen
                              : SpinColors.errorRed))),
                ])),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection5() {
    double totalDiffTotal = 0;

    // Recalculate diff total again...
    double totalPct = cottons.fold(0, (sum, c) => sum + c.percentage);
    double avgCostLbCd = 0;
    double avgCostLbCm = 0;
    double avgComberNoil = 0;

    if (totalPct > 0) {
      for (var c in cottons) {
        double w = c.percentage / 100;
        avgComberNoil += (c.cdYield - c.cmYield) * w;
        double costCd =
            (c.cdYield > 0) ? (c.rateKg / 2.20462) / (c.cdYield / 100) : 0;
        double costCm =
            (c.cmYield > 0) ? (c.rateKg / 2.20462) / (c.cmYield / 100) : 0;
        avgCostLbCd += costCd * w;
        avgCostLbCm += costCm * w;
      }
    }

    double noilPriceLb = noilPriceKg / 2.20462;
    double noilDeductionLb = noilPriceLb * (avgComberNoil / 100);
    double netCombedCostLb = avgCostLbCm - noilDeductionLb;

    for (var c in counts) {
      int totalSpindles = c.frames * c.spindlesPerFrame;
      double lbsFrameDay = c.spindlesPerFrame * (c.ops / 16) * shiftsPerDay;
      double lbsDay = c.frames * lbsFrameDay;
      double makingCostDay = spindleCostPerShift * totalSpindles * shiftsPerDay;
      double makingLb = lbsDay > 0 ? makingCostDay / lbsDay : 0;

      double rawMatLb = c.blend == 'Combed' ? netCombedCostLb : avgCostLbCd;
      double totalMakRaw = makingLb + rawMatLb;
      double packingLb =
          c.channel == 'Export' ? exportPackingRateLb : localPackingRateLb;
      double grandTotal = totalMakRaw + packingLb;

      double diffLb = c.saleLb - grandTotal;
      double diffTotal = diffLb * lbsDay;
      totalDiffTotal += diffTotal;
    }

    double monthTotal = totalDiffTotal * workingDays;
    double yearTotal = monthTotal * 12;

    return InputCard(
      title: '5. Summary',
      child: ResponsiveResults(
        children: [
          SizedBox(
            width: 250,
            child: ResultTile(
              label: 'Profit/Loss Per Day',
              value: totalDiffTotal.toStringAsFixed(2),
              highlight: true,
            ),
          ),
          SizedBox(
            width: 250,
            child: ResultTile(
              label: 'Profit/Loss Per Month',
              value: monthTotal.toStringAsFixed(2),
              highlight: true,
            ),
          ),
          SizedBox(
            width: 250,
            child: ResultTile(
              label: 'Profit/Loss Per Year',
              value: yearTotal.toStringAsFixed(2),
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }
}
