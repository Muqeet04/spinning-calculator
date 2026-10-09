import 'package:flutter_test/flutter_test.dart';
import 'package:spin_logic/core/calc/humidity.dart';

void main() {
  group('HumidityCalculator', () {
    test('fahrenheit to celsius', () {
      expect(HumidityCalculator.fahrenheitToCelsius(32), closeTo(0, 0.01));
      expect(HumidityCalculator.fahrenheitToCelsius(212), closeTo(100, 0.01));
      expect(HumidityCalculator.fahrenheitToCelsius(77), closeTo(25, 0.01));
    });

    test('saturation vapor pressure at 20°C', () {
      final es = HumidityCalculator.saturationVaporPressure(20);
      // At 20°C, Es ≈ 23.37 hPa
      expect(es, closeTo(23.37, 0.5));
    });

    test('calculate RH with aspirated psychrometer', () {
      // Typical room: dry 77°F (25°C), wet 68°F (20°C)
      final result = HumidityCalculator.calculate(
        dryBulbF: 77,
        wetBulbF: 68,
      );
      expect(result.dryBulbC, closeTo(25, 0.01));
      expect(result.wetBulbC, closeTo(20, 0.01));
      // RH should be reasonable (around 55-65%)
      expect(result.relativeHumidity, greaterThan(40));
      expect(result.relativeHumidity, lessThan(80));
    });

    test('RH clamped to 0-100', () {
      // When wet bulb equals dry bulb, RH should be 100%
      final result = HumidityCalculator.calculate(
        dryBulbF: 77,
        wetBulbF: 77,
      );
      expect(result.relativeHumidity, closeTo(100, 0.01));
    });

    test('natural draft gives different RH', () {
      final aspirated = HumidityCalculator.calculate(
        dryBulbF: 80,
        wetBulbF: 70,
        isAspirated: true,
      );
      final natural = HumidityCalculator.calculate(
        dryBulbF: 80,
        wetBulbF: 70,
        isAspirated: false,
      );
      // Natural draft has higher A coefficient, so lower RH
      expect(natural.relativeHumidity, lessThan(aspirated.relativeHumidity));
    });
  });
}
