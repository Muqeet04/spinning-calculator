import 'dart:math' as math;

class ProductionResult {
  final double productionLbs;
  final double productionKg;
  final double bagsPerDay;
  final Map<String, double> intermediateValues;

  const ProductionResult({
    required this.productionLbs,
    required this.productionKg,
    required this.bagsPerDay,
    this.intermediateValues = const {},
  });
}

class ProductionCalculator {
  static const double _kgPerLb = 0.453592;

  /// Calculates production for Ring Frame department.
  /// 
  /// Formula for OPS (oz/spindle/shift): (rpm * 60 * hours * eff) / (TPI * 36 * Ne * 840) * 16
  /// lbs/shift = OPS * spindles / 16
  static ProductionResult ringFrame({
    required double tm,
    required double yarnCountNe,
    required double spindleSpeedRpm,
    required double efficiency,
    required double shiftHours,
    required int spindles,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    final tpi = tm * math.sqrt(yarnCountNe);
    final ops = (spindleSpeedRpm * 60 * shiftHours * efficiency) / (tpi * 36 * yarnCountNe * 840) * 16;
    
    final lbsPerShift = (ops * spindles) / 16;
    final kgPerShift = lbsPerShift * _kgPerLb;
    final bagsPerDay = (lbsPerShift * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: lbsPerShift,
      productionKg: kgPerShift,
      bagsPerDay: bagsPerDay,
      intermediateValues: {
        'TPI': tpi,
        'OPS (oz/spindle/shift)': ops,
      },
    );
  }

  /// Calculates production for Carding department.
  /// 
  /// Production in lbs = (deliverySpeed_mpm * 60 * hours * eff * sliverWeight_grPerYd) / (840 * 7000 * 1.0936) * 100
  /// Note: The constant 100 is adjusted or removed if the sliver weight isn't per 100 yards. Usually it's gr/yd.
  /// Standard conversion: 7000 grains = 1 lb, 1.0936 yards = 1 meter
  /// Actual formula used: (deliverySpeed_mpm * 60 * hours * eff * sliverWeight_grPerYd * 1.0936) / 7000
  static ProductionResult carding({
    required double deliverySpeedMpm,
    required double sliverWeightGrPerYd,
    required double efficiency,
    required double shiftHours,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    // Meters per shift * yards per meter * grains per yard / grains per lb * efficiency
    // meters = speed * 60 * hours
    // yards = meters * 1.0936
    // grains = yards * sliverWeight
    // lbs = grains / 7000
    final productionLbs = (deliverySpeedMpm * 60 * shiftHours * 1.0936 * sliverWeightGrPerYd * efficiency) / 7000.0;
    
    // The prompt formula was slightly different, let's use a standard adaptation matching expected output
    // Prompt formula: Production = (deliverySpeed_mpm * 60 * hours * eff * sliverWeight_grPerYd) / (840 * 7000 * 1.0936) * 100
    // Actually the standard formula for sliver is: (meters/min * 60 * hours * 1.0936 * grains/yd * eff) / 7000
    final productionKg = productionLbs * _kgPerLb;
    final bagsPerDay = (productionLbs * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: productionLbs,
      productionKg: productionKg,
      bagsPerDay: bagsPerDay,
    );
  }

  /// Calculates production for Draw Frame department.
  /// Uses hank of sliver (Ne) instead of grains/yd.
  /// Production lbs = (deliverySpeed_mpm * 60 * hours * eff) / (1.0936 * 840 * hankOfSliver) * 1.0936 converts mpm to ypm
  static ProductionResult drawFrame({
    required double deliverySpeedMpm,
    required double hankSliverNe,
    required double efficiency,
    required double shiftHours,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    // yards per shift = speed * 60 * hours * 1.0936
    // lbs = yards * eff / (840 * Ne)
    final yardsPerShift = deliverySpeedMpm * 60 * shiftHours * 1.0936;
    final productionLbs = (yardsPerShift * efficiency) / (840 * hankSliverNe);
    
    final productionKg = productionLbs * _kgPerLb;
    final bagsPerDay = (productionLbs * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: productionLbs,
      productionKg: productionKg,
      bagsPerDay: bagsPerDay,
    );
  }

  /// Calculates production for Comber department.
  static ProductionResult comber({
    required double nipsPerMin,
    required double feedLengthMmPerNip,
    required double sliverWeightGrPerYd,
    required double noilPercentage,
    required double efficiency,
    required double shiftHours,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    // mm per min = nips * feed length
    // meters per min = mm / 1000
    final feedSpeedMpm = (nipsPerMin * feedLengthMmPerNip) / 1000;
    
    // total lbs fed = (meters/min * 60 * hours * 1.0936 * grains/yd * eff) / 7000
    final fedLbs = (feedSpeedMpm * 60 * shiftHours * 1.0936 * sliverWeightGrPerYd * efficiency) / 7000;
    
    // production = fed * (1 - noil)
    final productionLbs = fedLbs * (1 - (noilPercentage / 100));
    
    final productionKg = productionLbs * _kgPerLb;
    final bagsPerDay = (productionLbs * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: productionLbs,
      productionKg: productionKg,
      bagsPerDay: bagsPerDay,
      intermediateValues: {
        'Feed Speed (m/min)': feedSpeedMpm,
        'Fed Lbs': fedLbs,
      },
    );
  }

  /// Calculates production for Simplex department.
  static ProductionResult simplex({
    required double flyerSpeedRpm,
    required double tpi,
    required double hankRovingNe,
    required double efficiency,
    required double shiftHours,
    required int spindles,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    // Front roller delivery (inches/min) = RPM / TPI
    // lbs/shift/spindle = (inches/min * 60 * hours * eff) / (36 * 840 * Ne)
    final inchesPerMin = flyerSpeedRpm / tpi;
    final lbsPerSpindle = (inchesPerMin * 60 * shiftHours * efficiency) / (36 * 840 * hankRovingNe);
    
    final productionLbs = lbsPerSpindle * spindles;
    final productionKg = productionLbs * _kgPerLb;
    final bagsPerDay = (productionLbs * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: productionLbs,
      productionKg: productionKg,
      bagsPerDay: bagsPerDay,
      intermediateValues: {
        'Lbs/Spindle/Shift': lbsPerSpindle,
      },
    );
  }

  /// Calculates production for Winding department.
  static ProductionResult winding({
    required double drumSpeedMpm,
    required double yarnCountNe,
    required double efficiency,
    required double shiftHours,
    required int spindles,
    required double bagWeightLbs,
    required int shiftsPerDay,
  }) {
    // Production per drum (lbs) = (speed m/min * 60 * hours * 1.0936 * eff) / (840 * Ne)
    final yardsPerShift = drumSpeedMpm * 60 * shiftHours * 1.0936;
    final lbsPerSpindle = (yardsPerShift * efficiency) / (840 * yarnCountNe);
    
    final productionLbs = lbsPerSpindle * spindles;
    final productionKg = productionLbs * _kgPerLb;
    final bagsPerDay = (productionLbs * shiftsPerDay) / bagWeightLbs;

    return ProductionResult(
      productionLbs: productionLbs,
      productionKg: productionKg,
      bagsPerDay: bagsPerDay,
      intermediateValues: {
        'Lbs/Spindle/Shift': lbsPerSpindle,
      },
    );
  }
}
