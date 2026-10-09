import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
// Inspect rendered page streams, rather than only PDF metadata or byte length.
// ignore: implementation_imports
import 'package:pdf/src/pdf/obj/object_stream.dart' show PdfObjectStream;
import 'package:pdf/widgets.dart' as pw;
import 'package:spin_logic/app/theme.dart';
import 'package:spin_logic/ui/screens/blow_room_waste_screen.dart';
import 'package:spin_logic/ui/screens/count_conversion_screen.dart';
import 'package:spin_logic/ui/screens/humidity_screen.dart';
import 'package:spin_logic/ui/screens/new_mills_plan_screen.dart';
import 'package:spin_logic/ui/screens/pressure_conversion_screen.dart';
import 'package:spin_logic/ui/screens/production_screen.dart';
import 'package:spin_logic/ui/screens/profit_loss_screen.dart';
import 'package:spin_logic/ui/screens/ring_doff_screen.dart';
import 'package:spin_logic/ui/screens/spin_plan_screen.dart';
import 'package:spin_logic/ui/screens/target_feasibility_screen.dart';
import 'package:spin_logic/ui/widgets/page_scaffold.dart';
import 'package:spin_logic/ui/widgets/pdf_report_helpers.dart';
import 'package:spin_logic/ui/widgets/styled_dropdown.dart';
import 'package:spin_logic/ui/widgets/styled_text_field.dart';

class _RenderedReport {
  const _RenderedReport(this.document, this.pages);

  final pw.Document document;
  final List<String> pages;

  String get text => pages.join(' ');
}

String _normalize(String text) =>
    text.replaceAll(RegExp(r'\s+'), ' ').trim().toLowerCase();

// Standard PDF fonts render text in escaped literal strings inside TJ arrays.
// Decode those strings after document.save() has painted the page contents.
String _decodePageText(PdfPage page) {
  final literals = <String>[];
  final literalPattern = RegExp(r'\(((?:\\[\s\S]|[^\\)])*)\)');
  for (final stream in page.contents.whereType<PdfObjectStream>()) {
    final source = latin1.decode(stream.buf.output());
    for (final match in literalPattern.allMatches(source)) {
      final encoded = match.group(1)!;
      final decoded = StringBuffer();
      for (var i = 0; i < encoded.length; i++) {
        if (encoded[i] != '\\') {
          decoded.write(encoded[i]);
          continue;
        }
        i++;
        final character = encoded[i];
        if (RegExp(r'[0-7]').hasMatch(character)) {
          var octal = character;
          for (var n = 0; n < 2 && i + 1 < encoded.length; n++) {
            if (!RegExp(r'[0-7]').hasMatch(encoded[i + 1])) break;
            octal += encoded[++i];
          }
          decoded.writeCharCode(int.parse(octal, radix: 8));
        } else {
          decoded.write(const {
                'n': '\n',
                'r': '\r',
                't': '\t',
                'b': '\b',
                'f': '\f',
              }[character] ??
              character);
        }
      }
      literals.add(decoded.toString());
    }
  }
  return _normalize(literals.join(' '));
}

Future<void> _mount(WidgetTester tester, Widget screen) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1600, 1200);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(ProviderScope(
    child: MaterialApp(theme: SpinLogicTheme.lightTheme, home: screen),
  ));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _enter(
  WidgetTester tester,
  String label,
  String value, {
  int index = 0,
}) async {
  final field = find.descendant(
    of: find.widgetWithText(StyledTextField, label).at(index),
    matching: find.byType(TextFormField),
  );
  expect(field, findsOneWidget, reason: 'Input field: $label');
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _select(
  WidgetTester tester,
  String label,
  String choice,
) async {
  final dropdown = find.widgetWithText(StyledDropdown<String>, label);
  await tester.ensureVisible(dropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(
    of: dropdown,
    matching: find.byType(DropdownButtonFormField<String>),
  ));
  await tester.pumpAndSettle();
  await tester.tap(find.text(choice).last);
  await tester.pumpAndSettle();
}

Future<void> _tableEntry(
  WidgetTester tester,
  int table,
  int field,
  String value,
) async {
  final input = find
      .descendant(
        of: find.byType(DataTable).at(table),
        matching: find.byType(TextFormField),
      )
      .at(field);
  await tester.enterText(input, value);
  await tester.pump();
}

Future<_RenderedReport> _render(
  WidgetTester tester,
  String artifactName, {
  PdfPageFormat pageFormat = PdfPageFormat.a4,
}) async {
  final scaffold = tester.widget<PageScaffold>(find.byType(PageScaffold));
  expect(scaffold.onGeneratePdfReport, isNotNull);
  final document = await scaffold.generateReportPdf(pageFormat: pageFormat);
  final bytes = await document.save();
  expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  final pages =
      document.document.pdfPageList.pages.map(_decodePageText).toList();
  expect(pages, isNotEmpty);
  for (var index = 0; index < pages.length; index++) {
    expect(pages[index], contains('mm spinning calculator'));
    expect(pages[index], contains('page ${index + 1} of ${pages.length}'));
  }
  expect(pages.join(' '), isNot(contains('this report captures')));
  if (Platform.environment['SPIN_PDF_QA'] == '1') {
    await tester.runAsync(() async {
      final directory = Directory('/tmp/spin-pdf-qa');
      await directory.create(recursive: true);
      await File('${directory.path}/$artifactName.pdf').writeAsBytes(bytes);
    });
  }
  return _RenderedReport(document, pages);
}

void _containsAll(_RenderedReport report, List<String> expected) {
  for (final text in expected) {
    expect(report.text, contains(_normalize(text)),
        reason: 'PDF must print $text');
  }
}

void main() {
  final modules = <({
    String name,
    Widget screen,
    Map<String, String> inputs,
    List<String> expected,
  })>[
    (
      name: 'production',
      screen: const ProductionScreen(),
      inputs: {},
      expected: [
        'Input Parameters',
        'Spindle Speed',
        '22000',
        'TPI',
        '22.77',
        'Bags / day',
        '19.93'
      ],
    ),
    (
      name: 'count',
      screen: const CountConversionScreen(),
      inputs: {'Value': '40'},
      expected: [
        'Count Converter',
        'Source Input Value',
        '40',
        'Tex',
        '14.7625',
        'Linear Density Calculator'
      ],
    ),
    (
      name: 'blow_room',
      screen: const BlowRoomWasteScreen(),
      inputs: {},
      expected: [
        'Cotton Mixing',
        'USA',
        'Overall Yield',
        '92.00%',
        'Avg Moisture',
        '8.50%',
        'Net Output',
        '875.0',
        'Combined Process'
      ],
    ),
    (
      name: 'profit_loss',
      screen: const ProfitLossScreen(),
      inputs: {},
      expected: [
        'Raw Material Cost',
        'Kg per maund',
        '37.3242',
        'Avg/Total',
        'Spindles/Frame',
        'Lbs/Frame/Day',
        'Packing/Lb',
        'Profit / Loss Per Day',
        '-1696320.00'
      ],
    ),
    (
      name: 'pressure',
      screen: const PressureConversionScreen(),
      inputs: {'Value': '1'},
      expected: [
        'Pressure value',
        '1',
        'Bar',
        'PSI',
        '14.504',
        'mmHg',
        '750.1',
        'Atm',
        '0.9869'
      ],
    ),
    (
      name: 'humidity',
      screen: const HumidityScreen(),
      inputs: {
        'Dry bulb temperature (°F)': '77',
        'Wet bulb temperature (°F)': '68'
      },
      expected: [
        'Atmospheric pressure',
        '1013.25',
        'Dry bulb temperature (°C)',
        '25.00',
        'Wet bulb temperature (°C)',
        '20.00',
        'Relative humidity (%)',
        '63.20',
        'Typical Relative Humidity Targets'
      ],
    ),
    (
      name: 'target',
      screen: const TargetFeasibilityScreen(),
      inputs: {},
      expected: [
        'Target Yarn Count',
        '40.0 Ne',
        'Spinnable with comfortable safety margin',
        'Target TPI',
        '23.08',
        'Recommended Trial',
        'Monitor nep levels closely'
      ],
    ),
    (
      name: 'ring_doff',
      screen: const RingDoffScreen(),
      inputs: {},
      expected: [
        'Ring Frame',
        'Frame Spindles',
        '1824',
        'Ring Doff Time',
        '125.39',
        'Roving Consumption',
        '944.73 kg',
        'Doffs / Day'
      ],
    ),
    (
      name: 'new_mills',
      screen: const NewMillsPlanScreen(),
      inputs: {},
      expected: [
        'Mill Setup',
        'Spindles/Frame (Ring)',
        '1824',
        'Bags Required',
        'Total Bags Required',
        '200',
        'No data rows are currently shown',
        'Simplex',
        '2 (240 flyers)',
        'Summary Table',
        '36480',
        'sample data currently shown'
      ],
    ),
    (
      name: 'spin_plan',
      screen: const SpinPlanScreen(),
      inputs: {},
      expected: [
        'Plant Setup',
        'Ring Frames Count-wise',
        'OPS',
        '6.02',
        'Machines Available',
        '18240',
        'Balanced Plan by Department',
        'Run speed (% of set)',
        'Autocone winders',
        'Summary table would go here',
        'sample data currently shown'
      ],
    ),
  ];

  for (final module in modules) {
    testWidgets('${module.name} exports actual inputs and results',
        (tester) async {
      await _mount(tester, module.screen);
      for (final input in module.inputs.entries) {
        await _enter(tester, input.key, input.value);
      }
      expect(find.text('Print'), findsOneWidget);
      expect(find.text('Save PDF'), findsOneWidget);
      _containsAll(
          await _render(tester, 'module_${module.name}'), module.expected);
    });
  }

  testWidgets('count report reflects edits in both conversion cards',
      (tester) async {
    await _mount(tester, const CountConversionScreen());
    await _enter(tester, 'Value', '20');
    await _select(tester, 'Common sample length', '100 m');
    await _enter(tester, 'Weight', '1');
    final report = await _render(tester, 'edited_count');
    _containsAll(report, [
      'Source Input Value: 20',
      '29.5250',
      'Common Sample Length',
      '100 m',
      'Weight: 1 g',
      '10.0000',
      '59.0500'
    ]);
  });

  testWidgets('all production departments export their edited production',
      (tester) async {
    await _mount(tester, const ProductionScreen());
    final departments = <({
      String name,
      String artifact,
      Map<String, String> inputs,
      List<String> expected,
    })>[
      (
        name: 'Ring frame (spinning)',
        artifact: 'ring_frame',
        inputs: {
          'Spindle speed (RPM)': '10080',
          'Count (Ne)': '1',
          'Twist multiplier (TM)': '1',
          'No. of spindles': '1'
        },
        expected: [
          'OPS (oz/spl/shift)',
          '320.00',
          'Lbs / shift',
          '20.00',
          'Bags / day',
          '0.20'
        ],
      ),
      (
        name: 'Carding',
        artifact: 'carding',
        inputs: {
          'Delivery speed (m/min)': '100',
          'Sliver weight (grains/yard)': '70',
          'No. of cards': '2'
        },
        expected: [
          'No. of Cards',
          '2',
          'Lbs / shift',
          '131.23',
          'Bags / day',
          '1.31'
        ],
      ),
      (
        name: 'Draw frame',
        artifact: 'draw_frame',
        inputs: {
          'Delivery speed (m/min)': '100',
          'Sliver weight (grains/yard)': '70',
          'No. of deliveries': '2'
        },
        expected: [
          'Deliveries',
          '2',
          'Lbs / shift',
          '131.23',
          'Bags / day',
          '1.31'
        ],
      ),
      (
        name: 'Comber',
        artifact: 'comber',
        inputs: {
          'Nips per minute': '100',
          'Feed length (mm)': '10',
          'Noil %': '20',
          'Lap weight (grains/yard)': '700',
          'No. of heads': '1',
          'No. of combers': '1'
        },
        expected: [
          'Noil %',
          '20%',
          'Lbs / shift',
          '5.25',
          'Noil Lbs / shift',
          '1.31',
          'Bags / day',
          '0.05'
        ],
      ),
      (
        name: 'Simplex (speed frame)',
        artifact: 'simplex',
        inputs: {
          'Flyer speed (RPM)': '840',
          'TPI': '1',
          'Hank of roving': '1',
          'No. of spindles': '1',
          'No. of frames': '1'
        },
        expected: [
          'Flyer Speed',
          '840 RPM',
          'Lbs / shift',
          '1.67',
          'Bags / day',
          '0.02'
        ],
      ),
      (
        name: 'Winding (autoconer)',
        artifact: 'winding',
        inputs: {
          'Winding speed (m/min)': '100',
          'Count (Ne)': '1',
          'No. of spindles': '1'
        },
        expected: [
          'Winding Speed',
          '100 m/min',
          'Lbs / spl / shift',
          '7.81',
          'Bags / day',
          '0.08'
        ],
      ),
    ];
    for (final department in departments) {
      await _select(tester, 'Department', department.name);
      for (final input in department.inputs.entries) {
        await _enter(tester, input.key, input.value);
      }
      await _enter(tester, 'Efficiency (%)', '100');
      await _enter(tester, 'Shift hours', '1');
      await _enter(tester, 'Bag weight (kg)', '45.3592');
      await _enter(tester, 'Shifts/day', '1');
      final report = await _render(tester, 'production_${department.artifact}');
      _containsAll(
          report, ['Department: ${department.name}', ...department.expected]);
    }
  });

  testWidgets('spin plan prints edited fleet values after dropdown rebuild',
      (tester) async {
    await _mount(tester, const SpinPlanScreen());
    await _enter(tester, 'Mill Name', 'QA Spin Mill');
    await _enter(tester, 'Autocone spindles', '527');
    await _enter(tester, 'Cards', '13');
    await _select(tester, 'Balance by', 'Decimal machines');
    _containsAll(await _render(tester, 'edited_spin_plan'), [
      'Mill Name: QA Spin Mill',
      'Autocone spindles: 527',
      'Cards: 13',
      'Balance by: Decimal machines',
      'sample data currently shown',
      '18240'
    ]);
  });

  testWidgets('new mills report prints edited setup and displayed sample',
      (tester) async {
    await _mount(tester, const NewMillsPlanScreen());
    await _enter(tester, 'Mill Name', 'QA New Mill');
    await _enter(tester, 'Spindles/Frame (Ring)', '1200');
    await _enter(tester, 'Working hours/day', '20');
    await _select(tester, 'Card Feed Width', 'Narrow (55 kg/hr)');
    _containsAll(await _render(tester, 'edited_new_mills'), [
      'Mill Name: QA New Mill',
      'Spindles/Frame (Ring): 1200',
      'Working hours/day: 20',
      'Narrow (55 kg/hr)',
      'Total Bags Required: 200',
      'sample data currently shown'
    ]);
  });

  testWidgets('profit report preserves setup, all cost components and totals',
      (tester) async {
    await _mount(tester, const ProfitLossScreen());
    await _enter(tester, '1 maund = how many kg', '10');
    await _enter(tester, 'Noil price /kg', '2.20462');
    await _enter(tester, 'Working days per month', '5');
    await _enter(tester, 'Export packing rate /lb', '2');
    await _enter(tester, 'Local packing rate /lb', '3');
    await _enter(tester, 'Spindle cost /spindle/shift', '4');
    await _tableEntry(tester, 0, 0, 'QA Cotton');
    await _tableEntry(tester, 0, 1, '2.20462');
    await _tableEntry(tester, 0, 2, '100');
    await _tableEntry(tester, 0, 3, '100');
    await _tableEntry(tester, 0, 4, '100');
    for (var row = 0; row < 2; row++) {
      await _tableEntry(tester, 1, row * 4 + 1, '16');
      await _tableEntry(tester, 1, row * 4 + 2, '1');
      await _tableEntry(tester, 1, row * 4 + 3, '16');
      await _tableEntry(tester, 2, row, row == 0 ? '10' : '12');
    }
    _containsAll(await _render(tester, 'edited_profit_loss'), [
      'QA Cotton',
      'Kg per maund: 10.0000',
      'Export packing rate / lb: 2.00',
      'Local packing rate / lb: 3.00',
      'Spindle cost / spindle / shift: 4.00',
      'Spindles/Frame',
      'Lbs/Frame/Day',
      'Total (Making+Raw)',
      'Packing/Lb',
      'Grand Total Cost/Lb',
      '7.0000',
      '8.0000',
      'Profit / Loss Per Day',
      '336.00',
      '1680.00',
      '20160.00'
    ]);
  });

  testWidgets('ring doff report reflects edited count and derived packages',
      (tester) async {
    await _mount(tester, const RingDoffScreen());
    await _enter(tester, 'Yarn count (Ne)', '20');
    await _enter(tester, 'Frame spindles', '1000');
    _containsAll(await _render(tester, 'edited_ring_doff'), [
      'Yarn Count (Ne): 20',
      'Spindle Speed (RPM): 15500.00',
      'Frame Spindles: 1000',
      'Roving Pkgs / Day / Frame',
      '490.09',
      '882.15 kg'
    ]);
  });

  testWidgets('target count report reflects revised feasibility and trial',
      (tester) async {
    await _mount(tester, const TargetFeasibilityScreen());
    await _enter(tester, 'Target count (Ne)', '80');
    await _enter(tester, 'Fibre strength (g/tex)', '25');
    await _select(tester, 'Spinning route', 'Combed compact');
    _containsAll(await _render(tester, 'edited_target'), [
      '80.0 Ne',
      'High risk / marginal spinnability',
      'Fibre strength is low',
      'Trial with Combed compact route recommended'
    ]);
  });

  testWidgets('invalid count is printed with its validation message',
      (tester) async {
    await _mount(tester, const CountConversionScreen());
    await _enter(tester, 'Value', '0');
    _containsAll(await _render(tester, 'error_count'),
        ['Source Input Value: 0', 'Enter a valid positive number']);
  });

  testWidgets('invalid pressure is printed without fabricated results',
      (tester) async {
    await _mount(tester, const PressureConversionScreen());
    await _enter(tester, 'Value', '0');
    final report = await _render(tester, 'error_pressure');
    _containsAll(report, [
      'Pressure value: 0',
      'Results unavailable',
      'valid positive pressure value'
    ]);
    expect(report.text, isNot(contains('converted value')));
  });

  testWidgets('invalid humidity retains readings, error and typical targets',
      (tester) async {
    await _mount(tester, const HumidityScreen());
    await _enter(tester, 'Dry bulb temperature (°F)', '77');
    await _enter(tester, 'Wet bulb temperature (°F)', '80');
    _containsAll(await _render(tester, 'error_humidity'), [
      '77',
      '80',
      'Results unavailable',
      'Wet bulb temperature must be less than or equal',
      'Typical Relative Humidity Targets',
      'Blow room / Carding',
      'Winding'
    ]);
  });

  testWidgets('waste report retains an invalid feed warning and inputs',
      (tester) async {
    await _mount(tester, const BlowRoomWasteScreen());
    await _enter(tester, 'Total waste (kg)', '1500');
    _containsAll(await _render(tester, 'error_blow_room'),
        ['waste cannot exceed feed', '1000.0', '1500.0', '-500.0']);
  });

  testWidgets('long tables print every row and repeat continuation headers',
      (tester) async {
    await _mount(
        tester,
        PageScaffold(
          title: 'Long table regression',
          child: const SizedBox.shrink(),
          onGeneratePdfReport: (_) async => [
            PdfReportHelpers.dataTable(
              headers: ['Sample ID', 'Quality Result'],
              rows: List.generate(
                  120,
                  (index) => [
                        'QA-${index.toString().padLeft(3, '0')}',
                        'Result-$index'
                      ]),
            ),
          ],
        ));
    final report = await _render(tester, 'long_table');
    expect(report.pages.length, greaterThan(2));
    for (final page in report.pages) {
      expect(page, contains('sample id'));
      expect(page, contains('quality result'));
    }
    for (var index = 0; index < 120; index++) {
      expect(report.text, contains('qa-${index.toString().padLeft(3, '0')}'));
      expect(report.text, contains('result-$index'));
    }
    expect(report.pages.last, contains('qa-119'));
  });

  testWidgets('printer page format is honored by report generation',
      (tester) async {
    await _mount(
        tester,
        PageScaffold(
          title: 'Printer format regression',
          child: const SizedBox.shrink(),
          onGeneratePdfReport: (_) async =>
              [pw.Text('Actual calculation result: 42')],
        ));
    final report = await _render(tester, 'printer_letter',
        pageFormat: PdfPageFormat.letter);
    final page = report.document.document.pdfPageList.pages.single;
    expect(page.pageFormat.width, PdfPageFormat.letter.width);
    expect(page.pageFormat.height, PdfPageFormat.letter.height);
    _containsAll(report, ['Actual calculation result: 42']);
  });

  test('report builder failures propagate instead of generating generic PDFs',
      () async {
    final scaffold = PageScaffold(
      title: 'Broken calculation',
      child: const SizedBox.shrink(),
      onGeneratePdfReport: (_) async => throw StateError('Calculation failed'),
    );
    await expectLater(
        scaffold.generateReportPdf(),
        throwsA(isA<StateError>().having(
            (error) => error.message, 'message', 'Calculation failed')));
  });

  test('empty and missing report builders are rejected', () async {
    const missing = PageScaffold(title: 'No module', child: SizedBox.shrink());
    final empty = PageScaffold(
        title: 'Empty module',
        child: const SizedBox.shrink(),
        onGeneratePdfReport: (_) async => []);
    await expectLater(missing.generateReportPdf(), throwsStateError);
    await expectLater(empty.generateReportPdf(), throwsStateError);
  });
}
