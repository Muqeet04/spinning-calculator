import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:spin_logic/app/router.dart' as app;
import 'package:spin_logic/app/theme.dart';
import 'package:spin_logic/ui/screens/home_screen.dart';
import 'package:spin_logic/ui/screens/production_screen.dart';
import 'package:spin_logic/ui/screens/count_conversion_screen.dart';
import 'package:spin_logic/ui/screens/blow_room_waste_screen.dart';
import 'package:spin_logic/ui/screens/profit_loss_screen.dart';
import 'package:spin_logic/ui/screens/pressure_conversion_screen.dart';
import 'package:spin_logic/ui/screens/humidity_screen.dart';
import 'package:spin_logic/ui/screens/target_feasibility_screen.dart';
import 'package:spin_logic/ui/screens/ring_doff_screen.dart';
import 'package:spin_logic/ui/screens/new_mills_plan_screen.dart';
import 'package:spin_logic/ui/screens/spin_plan_screen.dart';
import 'package:spin_logic/ui/widgets/styled_text_field.dart';
import 'package:spin_logic/ui/widgets/responsive_layout.dart';

const screens = <String, Widget>{
  'home': HomeScreen(),
  'production': ProductionScreen(),
  'count': CountConversionScreen(),
  'waste': BlowRoomWasteScreen(),
  'profit': ProfitLossScreen(),
  'pressure': PressureConversionScreen(),
  'humidity': HumidityScreen(),
  'target': TargetFeasibilityScreen(),
  'ring': RingDoffScreen(),
  'new_mills': NewMillsPlanScreen(),
  'spin': SpinPlanScreen(),
};

Future<void> mount(
  WidgetTester tester,
  Widget screen,
  Size size, {
  double scale = 1,
  double keyboard = 0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: SpinLogicTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    // Use the SDK's real fonts so phone-width assertions reflect text metrics.
    final configFile = File('.dart_tool/package_config.json').absolute;
    final packages =
        jsonDecode(await configFile.readAsString())['packages'] as List;
    final flutter = packages.firstWhere(
      (package) => package['name'] == 'flutter',
    );
    final sdk = Directory.fromUri(
      configFile.uri.resolve(flutter['rootUri']),
    ).parent.parent;
    for (final family in ['Roboto', 'MaterialIcons']) {
      final loader = FontLoader(family);
      final fonts = family == 'Roboto'
          ? ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf']
          : ['MaterialIcons-Regular.otf'];
      for (final font in fonts) {
        final bytes = await File(
          '${sdk.path}/bin/cache/artifacts/material_fonts/$font',
        ).readAsBytes();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }
  });

  const sizes = [
    Size(320, 740),
    Size(360, 800),
    Size(390, 844),
    Size(430, 932),
    Size(844, 390),
    Size(1024, 768),
    Size(1600, 1200),
  ];
  for (final size in sizes) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('all screens fit $size at text scale $scale', (tester) async {
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        for (final screen in screens.entries) {
          final errors = <String>[];
          final previous = FlutterError.onError;
          FlutterError.onError = (details) =>
              errors.add('${details.exceptionAsString()} ${details.context}');
          try {
            await mount(tester, screen.value, size, scale: scale);
            final scrollable = find.byType(Scrollable).first;
            final state = tester.state<ScrollableState>(scrollable.first);
            state.position.jumpTo(state.position.maxScrollExtent);
            await tester.pumpAndSettle();
          } finally {
            FlutterError.onError = previous;
          }
          expect(errors, isEmpty, reason: '${screen.key}: $errors');
        }
      });
    }
  }

  testWidgets('phone header actions and menu navigation are reachable', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 740);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final router = GoRouter(
      initialLocation: '/count',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/count',
          builder: (_, __) => const CountConversionScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: SpinLogicTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byTooltip('Actions')).height,
      greaterThanOrEqualTo(48),
    );
    await tester.tap(find.byTooltip('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('Print'), findsOneWidget);
    expect(find.text('Save PDF'), findsOneWidget);
    await tester.tap(find.text('Save data'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Data saved successfully'), findsOneWidget);
    await tester.tap(find.byTooltip('Back to Menu'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'edited input survives changing between stacked and wide layouts',
    (tester) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await mount(tester, const CountConversionScreen(), const Size(390, 844));
      final field = find.descendant(
        of: find.widgetWithText(StyledTextField, 'Value'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(field, '42.75');
      tester.view.physicalSize = const Size(1024, 768);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(
              find.descendant(of: field, matching: find.byType(EditableText)),
            )
            .controller
            .text,
        '42.75',
      );
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<EditableText>(
              find.descendant(of: field, matching: find.byType(EditableText)),
            )
            .controller
            .text,
        '42.75',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('every module opens from the phone menu and returns home', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    app.router.go('/');
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          theme: SpinLogicTheme.lightTheme,
          routerConfig: app.router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    const modules = {
      'Production Calculation': ProductionScreen,
      'Count Conversion': CountConversionScreen,
      'Blow Room & Card Waste': BlowRoomWasteScreen,
      'Profit/Loss Calculations': ProfitLossScreen,
      'Pressure Conversion': PressureConversionScreen,
      'Relative Humidity Calculator': HumidityScreen,
      'Target Count Feasibility': TargetFeasibilityScreen,
      'Ring Doff & Roving Consumption': RingDoffScreen,
      'New Mills Plan': NewMillsPlanScreen,
      'Spin Plan (auto-balance)': SpinPlanScreen,
    };
    for (final module in modules.entries) {
      await tester.ensureVisible(find.text(module.key));
      await tester.pumpAndSettle();
      await tester.tap(find.text(module.key));
      await tester.pumpAndSettle();
      expect(find.byType(module.value), findsOneWidget);
      await tester.tap(find.byTooltip('Back to Menu'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('wide tables expose their remaining columns by a phone swipe', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await mount(tester, const ProfitLossScreen(), const Size(390, 844));
    final table = find.byType(ResponsiveTable).first;
    expect(find.text('Scroll sideways to see all columns'), findsWidgets);
    final scrollable = find.descendant(
      of: table,
      matching: find.byType(Scrollable),
    );
    final state = tester.state<ScrollableState>(scrollable.first);
    expect(state.position.pixels, 0);
    await tester.drag(table, const Offset(-260, 0));
    await tester.pumpAndSettle();
    expect(state.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keyboard leaves phone fields visible and scrollable', (
    tester,
  ) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await mount(
      tester,
      const ProfitLossScreen(),
      const Size(390, 844),
      keyboard: 320,
    );
    final field = find.widgetWithText(StyledTextField, 'Noil price /kg');
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    expect(tester.getRect(field).bottom, lessThanOrEqualTo(524));
    expect(tester.takeException(), isNull);
  });

  if (Platform.environment['SPIN_MOBILE_QA'] == '1') {
    testWidgets('render phone previews', (tester) async {
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final directory = Directory('/tmp/spin-mobile-qa');
      await tester.runAsync(() => directory.create(recursive: true));
      for (final name in ['home', 'production', 'ring', 'profit']) {
        final key = GlobalKey();
        await mount(
          tester,
          RepaintBoundary(key: key, child: screens[name]!),
          const Size(390, 844),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/images/logo.png'),
            key.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '${directory.path}/$name.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}
