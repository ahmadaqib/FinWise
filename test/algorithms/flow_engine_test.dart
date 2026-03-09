import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/flow_engine.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('FlowEngine Tests', () {
    test('Zone targets calculation from percentages', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 0,
        spentFlow: 0,
        spentGrow: 0,
        spentFree: 0,
        remainingDays: 30,
        totalDaysInMonth: 30,
      );

      expect(engine.targetShield, 300000);
      expect(engine.targetFlow, 300000);
      expect(engine.targetGrow, 300000);
      expect(engine.targetFree, 100000);
    });

    test('Efficiency score = 100 when all zones under budget', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 100000,
        spentFlow: 100000,
        spentGrow: 100000,
        spentFree: 50000,
        remainingDays: 15,
        totalDaysInMonth: 30,
      );

      expect(engine.zoneEfficiencyScore, 100.0);
    });

    test('Efficiency score degrades when overspent', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 400000, // +100k (33% over)
        spentFlow: 300000,
        spentGrow: 300000,
        spentFree: 100000,
        remainingDays: 15,
        totalDaysInMonth: 30,
      );

      // shieldScore = 100 - (1.333 - 1) * 100 = 66.666
      // Score = (66.666 * 0.25) + (100 * 0.25) + (100 * 0.35) + (100 * 0.15) = 91.666
      expect(engine.zoneEfficiencyScore, closeTo(91.66, 0.01));
    });

    test('Adaptive limit calculation with velocity 1.0', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 300000,
        spentShield: 0,
        spentFlow: 0,
        spentGrow: 0,
        spentFree: 0,
        remainingDays: 30,
        totalDaysInMonth: 30,
        behaviorSpendingVelocity: 1.0,
      );

      expect(engine.adaptiveDailySafeLimit, 10000.0);
    });

    test('Auto-brake activates when spending faster than time', () {
      // 50% money gone, but only 20% time gone (day 6 of 30)
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 500000,
        spentFlow: 0,
        spentGrow: 0,
        spentFree: 0,
        remainingDays: 24,
        totalDaysInMonth: 30,
      );

      // baseLimit = 500k / 24 = 20833
      // budgetRatio = 500k / 1M = 0.5
      // daysRatio = 24 / 30 = 0.8
      // mod = 0.5 / 0.8 = 0.625
      // limit = 20833 * 0.625 = 13020.83
      expect(engine.adaptiveDailySafeLimit, closeTo(13020.83, 0.01));
    });

    test('Adaptive limit with negative remaining budget is clamped to 0', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 1200000, // Overspent!
        spentFlow: 0,
        spentGrow: 0,
        spentFree: 0,
        remainingDays: 10,
        totalDaysInMonth: 30,
      );

      expect(engine.adaptiveDailySafeLimit, 0.0);
    });

    test('Adaptive limit with 0 remaining days', () {
      final engine = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 1000000,
        spentShield: 900000,
        spentFlow: 0,
        spentGrow: 0,
        spentFree: 0,
        remainingDays: 0,
        totalDaysInMonth: 30,
      );

      expect(engine.adaptiveDailySafeLimit, 100000.0);
    });
  });
}
