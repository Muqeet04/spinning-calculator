import 'dart:math' as math;

class HumidityResult {
  final double dryBulbC;
  final double wetBulbC;
  final double relativeHumidity;
  final double saturationPressureDry;
  final double saturationPressureWet;
  final double actualVaporPressure;

  const HumidityResult({
    required this.dryBulbC,
    required this.wetBulbC,
    required this.relativeHumidity,
    required this.saturationPressureDry,
    required this.saturationPressureWet,
    required this.actualVaporPressure,
  });
}

class HumidityCalculator {
  static double fahrenheitToCelsius(double f) {
    return (f - 32) * 5 / 9;
  }

  /// Saturation vapor pressure in hPa using Magnus formula
  static double saturationVaporPressure(double tempC) {
    return 6.112 * math.exp((17.62 * tempC) / (243.12 + tempC));
  }

  static HumidityResult calculate({
    required double dryBulbF,
    required double wetBulbF,
    double pressure = 1013.25,
    bool isAspirated = true,
  }) {
    final dryBulbC = fahrenheitToCelsius(dryBulbF);
    final wetBulbC = fahrenheitToCelsius(wetBulbF);

    // Psychrometer constant A
    final A = isAspirated ? 0.000662 : 0.0008;

    final esWet = saturationVaporPressure(wetBulbC);
    final esDry = saturationVaporPressure(dryBulbC);

    // Actual vapor pressure e = es(wet) - A * P * (Tdry - Twet)
    final actualVaporPressure = esWet - (A * pressure * (dryBulbC - wetBulbC));

    // Relative humidity
    double rh = (actualVaporPressure / esDry) * 100;
    
    // Clamp to 0-100 range
    rh = rh.clamp(0.0, 100.0);

    return HumidityResult(
      dryBulbC: dryBulbC,
      wetBulbC: wetBulbC,
      relativeHumidity: rh,
      saturationPressureDry: esDry,
      saturationPressureWet: esWet,
      actualVaporPressure: actualVaporPressure,
    );
  }
}
