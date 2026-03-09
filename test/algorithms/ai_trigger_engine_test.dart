import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/ai_trigger_engine.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('AiTriggerEngine Tests', () {
    test('High velocity triggers warning', () {
      final context = TestFixtures.mockAIContext(spendingVelocity: 1.5);
      final engine = AiTriggerEngine(context);
      final insights = engine.generateInsights();

      expect(insights.any((i) => i.title.contains('Laju Belanja')), isTrue);
    });

    test('Low FWS triggers fragile warning', () {
      final context = TestFixtures.mockAIContext(currentFWS: 150);
      final engine = AiTriggerEngine(context);
      final insights = engine.generateInsights();

      expect(insights.any((i) => i.title.contains('Keuangan Fragile')), isTrue);
    });

    test('Normal context generates zero insights', () {
      final context = TestFixtures.mockAIContext(
        spendingVelocity: 1.0,
        currentFWS: 500,
        freedomIndex: 10,
      );
      final engine = AiTriggerEngine(context);
      final insights = engine.generateInsights();

      expect(insights.isEmpty, isTrue);
    });
  });
}
