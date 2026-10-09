import 'package:flutter_test/flutter_test.dart';
import 'package:spin_logic/core/calc/pressure_conversion.dart';

void main() {
  group('PressureConversion', () {
    test('convert 1 bar to all units', () {
      final results = PressureConversion.convert(1, 'Bar');
      expect(results['Bar'], closeTo(1.0, 0.001));
      expect(results['PSI'], closeTo(14.5038, 0.01));
      expect(results['kg/cm²'], closeTo(1.01972, 0.001));
      expect(results['kPa'], closeTo(100.0, 0.1));
      expect(results['mmHg'], closeTo(750.062, 0.1));
      expect(results['Atm'], closeTo(0.98692, 0.001));
      expect(results['mBar'], closeTo(1000.0, 0.1));
    });

    test('convert from PSI to bar', () {
      final bar = PressureConversion.toBar(14.5038, 'PSI');
      expect(bar, closeTo(1.0, 0.001));
    });

    test('convert from kPa', () {
      final results = PressureConversion.convert(100, 'kPa');
      expect(results['Bar'], closeTo(1.0, 0.001));
    });

    test('convert from atm', () {
      final results = PressureConversion.convert(1, 'Atm');
      expect(results['Bar'], closeTo(1.01325, 0.01));
    });

    test('roundtrip for all units from 2.5 bar', () {
      final results = PressureConversion.convert(2.5, 'Bar');
      for (final entry in results.entries) {
        final backToBar = PressureConversion.toBar(entry.value, entry.key);
        expect(backToBar, closeTo(2.5, 0.01),
            reason: 'Roundtrip failed for ${entry.key}');
      }
    });
  });
}
