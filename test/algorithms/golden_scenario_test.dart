import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/flow_engine.dart';
import 'package:FinWise/algorithms/behavior_intelligence.dart';
import 'package:FinWise/algorithms/quadrant_tracker.dart';
import 'package:FinWise/algorithms/enough_anchor.dart';
import 'package:FinWise/algorithms/finwise_score.dart';
import 'package:FinWise/algorithms/ai_trigger_engine.dart';
import 'package:FinWise/data/models/ai_context_package.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('Golden Scenarios - End-to-End Logic', () {
    test('Scenario 1: Karyawan Disiplin (Stable/Growing)', () {
      // 10M Income (E), 5M Monthly Target
      final incomes = [
        TestFixtures.mockIncome(amount: 10000000, quadrant: 'E'),
      ];

      // Day 15/30, spent 2.5M (exactly on track)
      final txs = List.generate(
        15,
        (i) => TestFixtures.mockExpense(
          amount: 166666, // 2.5M / 15
          date: DateTime.now().subtract(Duration(days: 15 - i)),
          spendingMood: 'planned',
          transactionNature: 'none',
        ),
      );

      final quadrant = QuadrantTracker(incomeSources: incomes);
      final behavior = BehaviorIntelligence(
        transactions: txs,
        totalFreeBudget: 5000000,
        daysPassed: 15,
        totalDaysInMonth: 30,
      );

      final flow = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 5000000,
        spentShield: 1000000,
        spentFlow: 1000000,
        spentGrow: 500000,
        spentFree: 0,
        remainingDays: 15,
        totalDaysInMonth: 30,
        behaviorSpendingVelocity: behavior.spendingVelocityModifier,
      );

      final anchor = EnoughAnchor(
        currentEmergencyFund: 10000000,
        emergencyFundTarget: 20000000,
        currentPassiveIncome: 0,
        monthlyPassiveTarget: 5000000,
        currentNetWorth: 50000000,
        netWorthTarget: 100000000,
      );

      final score = FinWiseScore(
        flowScore: flow.zoneEfficiencyScore,
        quadrantScore: quadrant.freedomIndex,
        behaviorScore: 80, // mocked for simplicity
        anchorScore: anchor.anchorScore,
      );

      final fws = score.compute();

      // Expected: No freedom index (E only), good flow, good behavior
      expect(fws, greaterThan(400)); // At least Stable
      expect(flow.adaptiveDailySafeLimit, closeTo(166666, 1000));
    });

    test('Scenario 2: User Boros (Fragile)', () {
      final txs = [
        TestFixtures.mockExpense(amount: 4000000, spendingMood: 'impulsive'),
      ];

      final behavior = BehaviorIntelligence(
        transactions: txs,
        totalFreeBudget: 5000000,
        daysPassed: 2,
        totalDaysInMonth: 30,
      );

      final flow = FlowEngine(
        target: TestFixtures.defaultFlowZone(),
        totalFreeBudget: 5000000,
        spentShield: 4000000,
        spentFlow: 2000000,
        spentGrow: 2000000,
        spentFree: 1000000,
        remainingDays: 28,
        totalDaysInMonth: 30,
        behaviorSpendingVelocity: behavior.spendingVelocityModifier,
      );

      // All zones overspent (ratio > 1.0) -> scores < 100 or 0

      // velocity = 2M/day vs 166k/day = 12x
      // modifier = 1/12 = 0.08
      expect(flow.adaptiveDailySafeLimit, lessThan(10000));

      final score = FinWiseScore(
        flowScore: flow.zoneEfficiencyScore,
        quadrantScore: 0,
        behaviorScore: 5, // very high impulse
        anchorScore: 0,
      );

      expect(score.band, 'Fragile');

      final context = AIContextPackage(
        totalFixedIncome: 5000000,
        currentCicilan: 0,
        freeBudget: 5000000,
        remainingBudget: -4000000,
        adaptiveDailySafeLimit: flow.adaptiveDailySafeLimit,
        zoneDistribution: {},
        flowScore: flow.zoneEfficiencyScore,
        spendingVelocity: behavior.spendingVelocityModifier,
        incomeByQuadrant: {},
        freedomIndex: 0,
        trajectory: 'stable',
        spendingByDay: {},
        impulseRateOverall: behavior.impulseRateOverall,
        assetToLiabilityRatio: 0,
        topImpulseCategory: 'None',
        currentFWS: score.compute(),
        fwsDelta: 0,
        fwsBand: score.band,
        emergencyFundProgress: 0,
        enoughAnchorScore: 0,
      );

      final engine = AiTriggerEngine(context);
      final insights = engine.generateInsights();
      expect(insights.any((i) => i.type == 'warning'), isTrue);
    });
  });
}
