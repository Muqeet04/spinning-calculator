import 'package:flutter_test/flutter_test.dart';
import 'package:spin_logic/core/calc/count_conversion.dart';

void main() {
  group('CountConversion', () {
    test('convert from Ne 40 to all units', () {
      final results = CountConversion.convert(40, CountConversion.ne);
      expect(results[CountConversion.ne], closeTo(40.0, 0.01));
      expect(results[CountConversion.tex], closeTo(14.7625, 0.01));
      expect(results[CountConversion.nm], closeTo(67.73, 0.1));
      expect(results[CountConversion.denier], closeTo(132.86, 0.1));
    });

    test('convert from Tex 100', () {
      final results = CountConversion.convertFromTex(100);
      expect(results[CountConversion.ne], closeTo(5.905, 0.01));
      expect(results[CountConversion.nm], closeTo(10.0, 0.01));
      expect(results[CountConversion.denier], closeTo(900, 0.1));
      expect(results[CountConversion.dtex], closeTo(1000, 0.1));
      expect(results[CountConversion.ktex], closeTo(0.1, 0.001));
      expect(results[CountConversion.worsted], closeTo(8.8575, 0.01));
      expect(results[CountConversion.linen], closeTo(16.534, 0.01));
      expect(results[CountConversion.woollen], closeTo(19.376, 0.01));
      expect(results[CountConversion.grainsPerYd], closeTo(1.4112, 0.01));
    });

    test('toTex roundtrip for all units', () {
      const texValue = 50.0;
      final results = CountConversion.convertFromTex(texValue);
      for (final entry in results.entries) {
        final backToTex = CountConversion.toTex(entry.value, entry.key);
        expect(backToTex, closeTo(texValue, 0.01),
            reason: 'Roundtrip failed for ${entry.key}');
      }
    });

    test('texFromLengthWeight - 120 yd, 5.67 g gives Tex ~51.7', () {
      const lengthMeters = 120 * 0.9144; // 120 yards to meters
      final tex = CountConversion.texFromLengthWeight(
        lengthMeters: lengthMeters,
        weightGrams: 5.67,
      );
      expect(tex, closeTo(51.7, 0.5));

      // From that Tex, Ne should be about 11.4
      final results = CountConversion.convertFromTex(tex);
      expect(results[CountConversion.ne], closeTo(11.4, 0.2));
    });

    test('invalid inputs return empty or zero', () {
      expect(CountConversion.convertFromTex(0), isEmpty);
      expect(CountConversion.convertFromTex(-5), isEmpty);
      expect(CountConversion.toTex(0, CountConversion.ne), equals(0.0));
      expect(CountConversion.toTex(-1, CountConversion.ne), equals(0.0));
      expect(CountConversion.texFromLengthWeight(lengthMeters: 0, weightGrams: 5), equals(0.0));
    });
  });
}
