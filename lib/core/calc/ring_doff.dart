import 'dart:math' as math;

class RingDoffResult {
  final double tm;
  final double ops;
  final double outputPerSpindlePerHourG;
  final double doffTimeMin;
  final double doffsPerDay;
  final double rovingPackagesPerDayPerFrame;
  final double rovingPackagesPerShift;
  final double rovingPackagesPerDoffChange;
  final double yarnProductionPerDayPerFrameKg;
  final double timeToConsumeRovingHours;
  final double daysToConsumeRoving;

  const RingDoffResult({
    required this.tm,
    required this.ops,
    required this.outputPerSpindlePerHourG,
    required this.doffTimeMin,
    required this.doffsPerDay,
    required this.rovingPackagesPerDayPerFrame,
    required this.rovingPackagesPerShift,
    required this.rovingPackagesPerDoffChange,
    required this.yarnProductionPerDayPerFrameKg,
    required this.timeToConsumeRovingHours,
    required this.daysToConsumeRoving,
  });
}

class RingDoffCalculator {
  static RingDoffResult calculate({
    required double yarnCountNe,
    required double spindleSpeedRpm,
    required double tpiValue,
    required double bobbinWeightG,
    required double rovingPackageWeightG,
    required double ringCupDiameterMm,
    required int frameSpindles,
    required double shiftHours,
    double efficiency = 0.9696485558,
  }) {
    // TM = TPI / sqrt(Ne)
    final tm = tpiValue / math.sqrt(yarnCountNe);

    // OPS (oz/spindle/shift)
    // Formula: (rpm * 60 * shiftHours * eff) / (TPI * 36 * Ne * 840) * 16
    final ops = (spindleSpeedRpm * 60 * shiftHours * efficiency) / (tpiValue * 36 * yarnCountNe * 840) * 16;

    // Output per spindle per hour (g)
    // Formula: (spindleSpeed * 60 * eff) / (TPI * 36 * Ne * 840) * 453.592
    final outputPerSpindlePerHourG = (spindleSpeedRpm * 60 * efficiency) / (tpiValue * 36 * yarnCountNe * 840) * 453.592;

    // Ring doff time (min) = bobbinWeightG / outputPerSpindlePerHourG * 60
    final doffTimeMin = (bobbinWeightG / outputPerSpindlePerHourG) * 60;

    // Doffs per day = 1440 / (doffTime + 3)  [3 min doff change time]
    final doffsPerDay = 1440 / (doffTimeMin + 3);

    // Roving packages per day per frame = (outputPerSpindlePerHourG * 24 * frameSpindles) / rovingPackageWeightG
    final rovingPackagesPerDayPerFrame = (outputPerSpindlePerHourG * 24 * frameSpindles) / rovingPackageWeightG;

    // Roving packages per shift (original reference uses 2 shifts/day or 12h per shift basis -> 314.95)
    final rovingPackagesPerShift = rovingPackagesPerDayPerFrame / 2;

    // Roving packages per doff change = rovingPackagesPerDay / doffsPerDay
    final rovingPackagesPerDoffChange = rovingPackagesPerDayPerFrame / doffsPerDay;

    // Yarn production per day per frame (kg) = outputPerSpindlePerHourG * 24 * frameSpindles / 1000
    final yarnProductionPerDayPerFrameKg = (outputPerSpindlePerHourG * 24 * frameSpindles) / 1000;

    // Time to consume one roving package (hours) = rovingPackageWeightG / outputPerSpindlePerHourG
    final timeToConsumeRovingHours = rovingPackageWeightG / outputPerSpindlePerHourG;

    // Days to consume = timeToConsume / 24
    final daysToConsumeRoving = timeToConsumeRovingHours / 24;

    return RingDoffResult(
      tm: tm,
      ops: ops,
      outputPerSpindlePerHourG: outputPerSpindlePerHourG,
      doffTimeMin: doffTimeMin,
      doffsPerDay: doffsPerDay,
      rovingPackagesPerDayPerFrame: rovingPackagesPerDayPerFrame,
      rovingPackagesPerShift: rovingPackagesPerShift,
      rovingPackagesPerDoffChange: rovingPackagesPerDoffChange,
      yarnProductionPerDayPerFrameKg: yarnProductionPerDayPerFrameKg,
      timeToConsumeRovingHours: timeToConsumeRovingHours,
      daysToConsumeRoving: daysToConsumeRoving,
    );
  }
}
