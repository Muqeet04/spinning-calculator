import 'package:flutter_test/flutter_test.dart';
import 'package:spin_logic/core/calc/ring_doff.dart';

void main() {
  group('RingDoffCalculator', () {
    test('default values (Ne=40) match expected results', () {
      final result = RingDoffCalculator.calculate(
        yarnCountNe: 40,
        spindleSpeedRpm: 22712,
        tpiValue: 22.96,
        bobbinWeightG: 45.1,
        rovingPackageWeightG: 1500,
        ringCupDiameterMm: 38,
        frameSpindles: 1824,
        shiftHours: 8,
      );

      expect(result.tm, closeTo(3.630, 0.01));
      expect(result.ops, closeTo(6.09, 0.05));
      expect(result.outputPerSpindlePerHourG, closeTo(21.58, 0.1));
      expect(result.doffTimeMin, closeTo(125.37, 0.5));
      expect(result.doffsPerDay, closeTo(11.22, 0.1));
      expect(result.rovingPackagesPerDayPerFrame, closeTo(629.89, 1.0));
      expect(result.rovingPackagesPerShift, closeTo(314.95, 1.0));
      expect(result.rovingPackagesPerDoffChange, closeTo(56.15, 0.5));
      expect(result.yarnProductionPerDayPerFrameKg, closeTo(944.84, 2.0));
      expect(result.timeToConsumeRovingHours, closeTo(69.50, 0.5));
      expect(result.daysToConsumeRoving, closeTo(2.90, 0.05));
    });

    test('TM calculation is TPI / sqrt(Ne)', () {
      final result = RingDoffCalculator.calculate(
        yarnCountNe: 30,
        spindleSpeedRpm: 19500,
        tpiValue: 21.08,
        bobbinWeightG: 55,
        rovingPackageWeightG: 1600,
        ringCupDiameterMm: 38,
        frameSpindles: 1824,
        shiftHours: 8,
      );
      // TM = 21.08 / sqrt(30) ≈ 3.849
      expect(result.tm, closeTo(3.849, 0.01));
    });

    test('higher count produces lower OPS', () {
      final result30 = RingDoffCalculator.calculate(
        yarnCountNe: 30,
        spindleSpeedRpm: 19500,
        tpiValue: 21.08,
        bobbinWeightG: 55,
        rovingPackageWeightG: 1600,
        ringCupDiameterMm: 38,
        frameSpindles: 1824,
        shiftHours: 8,
      );
      final result60 = RingDoffCalculator.calculate(
        yarnCountNe: 60,
        spindleSpeedRpm: 21000,
        tpiValue: 27.89,
        bobbinWeightG: 33,
        rovingPackageWeightG: 1300,
        ringCupDiameterMm: 38,
        frameSpindles: 1824,
        shiftHours: 8,
      );
      expect(result60.ops, lessThan(result30.ops));
    });
  });
}
