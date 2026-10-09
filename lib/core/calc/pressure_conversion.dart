class PressureConversion {
  static const String bar = 'Bar';
  static const String psi = 'PSI';
  static const String kgCm2 = 'kg/cm²';
  static const String kpa = 'kPa';
  static const String mmhg = 'mmHg';
  static const String atm = 'Atm';
  static const String mbar = 'mBar';

  /// Converts from any unit to Bar
  static double toBar(double value, String fromUnit) {
    switch (fromUnit) {
      case bar:
        return value;
      case psi:
        return value / 14.5038;
      case kgCm2:
        return value / 1.01972;
      case kpa:
        return value / 100;
      case mmhg:
        return value / 750.062;
      case atm:
        return value / 0.98692;
      case mbar:
        return value / 1000;
      default:
        throw ArgumentError('Unsupported pressure unit: $fromUnit');
    }
  }

  /// Converts from any unit to all units, rounded to specified decimal places
  static Map<String, double> convert(double value, String fromUnit) {
    final barValue = toBar(value, fromUnit);
    
    return {
      bar: double.parse(barValue.toStringAsFixed(4)),
      psi: double.parse((barValue * 14.5038).toStringAsFixed(3)),
      kgCm2: double.parse((barValue * 1.01972).toStringAsFixed(4)),
      kpa: double.parse((barValue * 100).toStringAsFixed(2)),
      mmhg: double.parse((barValue * 750.062).toStringAsFixed(1)),
      atm: double.parse((barValue * 0.98692).toStringAsFixed(4)),
      mbar: double.parse((barValue * 1000).toStringAsFixed(1)),
    };
  }
}
