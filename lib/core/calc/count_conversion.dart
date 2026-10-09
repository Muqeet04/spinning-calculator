class CountConversion {
  static const String ne = 'Ne';
  static const String nm = 'Nm';
  static const String tex = 'Tex';
  static const String denier = 'Denier';
  static const String dtex = 'Dtex';
  static const String ktex = 'Ktex';
  static const String worsted = 'Worsted';
  static const String linen = 'Linen';
  static const String woollen = 'Woollen';
  static const String grainsPerYd = 'Grains/yd';

  // Length multipliers to meters
  static const double meters = 1.0;
  static const double yardsToMeters = 0.9144;
  static const double cmToMeters = 0.01;
  static const double inchesToMeters = 0.0254;
  static const double feetToMeters = 0.3048;

  // Weight multipliers to grams
  static const double grams = 1.0;
  static const double mgToGrams = 0.001;
  static const double kgToGrams = 1000.0;
  static const double grainsToGrams = 0.06479891;
  static const double ozToGrams = 28.3495;
  static const double lbToGrams = 453.592;

  /// Converts a given value in Tex to all other yarn count units
  static Map<String, double> convertFromTex(double texValue) {
    if (texValue <= 0) return {};
    return {
      ne: 590.5 / texValue,
      nm: 1000 / texValue,
      tex: texValue,
      denier: texValue * 9,
      dtex: texValue * 10,
      ktex: texValue / 1000,
      worsted: 885.75 / texValue,
      linen: 1653.4 / texValue,
      woollen: 1937.6 / texValue,
      grainsPerYd: texValue / 70.865,
    };
  }

  /// Converts a given value from any supported unit to Tex
  static double toTex(double value, String fromUnit) {
    if (value <= 0) return 0.0;
    switch (fromUnit) {
      case ne:
        return 590.5 / value;
      case nm:
        return 1000 / value;
      case tex:
        return value;
      case denier:
        return value / 9;
      case dtex:
        return value / 10;
      case ktex:
        return value * 1000;
      case worsted:
        return 885.75 / value;
      case linen:
        return 1653.4 / value;
      case woollen:
        return 1937.6 / value;
      case grainsPerYd:
        return value * 70.865;
      default:
        throw ArgumentError('Unsupported unit: $fromUnit');
    }
  }

  /// Converts a given value from any unit to all units
  static Map<String, double> convert(double value, String fromUnit) {
    final texValue = toTex(value, fromUnit);
    return convertFromTex(texValue);
  }

  /// Calculates Tex from length in meters and weight in grams
  static double texFromLengthWeight({
    required double lengthMeters,
    required double weightGrams,
  }) {
    if (lengthMeters <= 0) return 0.0;
    // Tex = weight in grams / length in km
    final lengthKm = lengthMeters / 1000;
    return weightGrams / lengthKm;
  }
}
