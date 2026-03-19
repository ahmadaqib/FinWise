import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/ai_trigger_engine.dart';
import 'package:FinWise/data/models/ai_context_package.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('AiTriggerEngine Extended Tests', () {
    test('Trigger Zone Overbudget alert when ZONE FLOW exceeds target', () {
      final context = TestFixtures.mockAIContext(
        freeBudget: 1000000,
        zoneDistribution: {
          'flow': 500000, // 50% (target is 45%)
        },
      );
      final engine = AiTriggerEngine(context);
      
      final insights = engine.generateInsights();
      
      expect(insights.any((i) => i.title.contains('Zone FLOW Overbudget')), isTrue);
    });

    test('Trigger Budget Menipis alert when remaining budget is low', () {
      final context = TestFixtures.mockAIContext(
        freeBudget: 100000, // Very low compared to limit
      );
      
      final engine = AiTriggerEngine(context);
      final insights = engine.generateInsights();
      
      expect(insights.any((i) => i.title.contains('Budget Menipis')), isTrue);
    });

    test('Trigger Emergency Fund Milestone alert at 10%', () {
      final contextWithEf = AIContextPackage(
        totalFixedIncome: 5000000,
        currentCicilan: 0,
        freeBudget: 1000000,
        remainingBudget: 1000000,
        adaptiveDailySafeLimit: 100000,
        zoneDistribution: {},
        flowScore: 100,
        spendingVelocity: 1.0,
        incomeByQuadrant: {},
        freedomIndex: 0,
        trajectory: 'stable',
        spendingByDay: {},
        impulseRateOverall: 0.1,
        assetToLiabilityRatio: 1.0,
        topImpulseCategory: 'None',
        currentFWS: 500.0,
        fwsDelta: 0,
        fwsBand: 'Stable',
        emergencyFundProgress: 10.5,
        enoughAnchorScore: 50.0,
      );
      
      final engine = AiTriggerEngine(contextWithEf);
      final insights = engine.generateInsights();
      
      expect(insights.any((i) => i.title.contains('Langkah Awal Aman')), isTrue);
    });
  });
}
