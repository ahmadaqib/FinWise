import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/behavior_intelligence.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('BehaviorIntelligence Tests', () {
    test('Velocity = 1.0 when spending matches ideal rate', () {
      final intel = BehaviorIntelligence(
        transactions: [
          TestFixtures.mockExpense(amount: 100000, date: DateTime.now()),
        ],
        totalFreeBudget: 3000000, // 100k/day for 30 days
        daysPassed: 1,
        totalDaysInMonth: 30,
      );

      expect(intel.spendingVelocityModifier, 1.0);
    });

    test('Velocity < 1.0 when overspending (auto-brake)', () {
      final intel = BehaviorIntelligence(
        transactions: [
          TestFixtures.mockExpense(amount: 400000, date: DateTime.now()),
        ],
        totalFreeBudget: 3000000, // 100k/day target
        daysPassed: 2, // actual 200k/day
        totalDaysInMonth: 30,
      );

      // idealDailyRate = 3M / 30 = 100k
      // actualDailyRate = 400k / 2 = 200k
      // ratio = 2.0
      // modifier = 1 / 2.0 = 0.5
      expect(intel.spendingVelocityModifier, 0.5);
      expect(intel.spendingVelocityRatio, 2.0);
    });

    test('Impulse rate overall calculation', () {
      final intel = BehaviorIntelligence(
        transactions: [
          TestFixtures.mockExpense(amount: 100, spendingMood: 'impulsive'),
          TestFixtures.mockExpense(amount: 100, spendingMood: 'planned'),
          TestFixtures.mockExpense(amount: 100, spendingMood: 'impulsive'),
        ],
        totalFreeBudget: 1000,
        daysPassed: 1,
        totalDaysInMonth: 30,
      );

      expect(intel.impulseRateOverall, 2 / 3);
    });

    test('Asset vs Liability ratio', () {
      final intel = BehaviorIntelligence(
        transactions: [
          TestFixtures.mockExpense(amount: 1000, transactionNature: 'asset'),
          TestFixtures.mockExpense(
            amount: 500,
            transactionNature: 'investment',
          ),
          TestFixtures.mockExpense(amount: 500, transactionNature: 'liability'),
        ],
        totalFreeBudget: 5000,
        daysPassed: 1,
        totalDaysInMonth: 30,
      );

      // Asset = 1500, Liability = 500
      expect(intel.assetToLiabilityRatio, 3.0);
    });

    test('Payday effect detection', () {
      // Week 1 high spending vs Week 4
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 2);
      final monthEnd = DateTime(now.year, now.month, 25);

      final intel = BehaviorIntelligence(
        transactions: [
          TestFixtures.mockExpense(
            amount: 7000,
            date: monthStart,
          ), // week 1: 1000/day
          TestFixtures.mockExpense(
            amount: 700,
            date: monthEnd,
          ), // week 4: 100/day
        ],
        totalFreeBudget: 10000,
        daysPassed: 25,
        totalDaysInMonth: 30,
      );

      expect(intel.hasPaydayEffect, isTrue);
    });
  });
}
