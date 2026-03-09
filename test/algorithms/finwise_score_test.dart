import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/finwise_score.dart';

void main() {
  group('FinWiseScore Tests', () {
    test('All 100 inputs = 1000 score', () {
      final score = FinWiseScore(
        flowScore: 100.0,
        quadrantScore: 100.0,
        behaviorScore: 100.0,
        anchorScore: 100.0,
      );

      expect(score.compute(), 1000.0);
      expect(score.band, 'Free');
    });

    test('All 0 inputs = 0 score', () {
      final score = FinWiseScore(
        flowScore: 0.0,
        quadrantScore: 0.0,
        behaviorScore: 0.0,
        anchorScore: 0.0,
      );

      expect(score.compute(), 0.0);
      expect(score.band, 'Fragile');
    });

    test('Weighted score calculation', () {
      // Flow 100 (30%), others 0
      final score = FinWiseScore(
        flowScore: 100.0,
        quadrantScore: 0.0,
        behaviorScore: 0.0,
        anchorScore: 0.0,
      );

      // (100 * 0.3) * 10 = 300
      expect(score.compute(), 300.0);
      expect(score.band, 'Surviving');
    });

    test('Band transitions', () {
      expect(
        FinWiseScore(
          flowScore: 100,
          quadrantScore: 100,
          behaviorScore: 100,
          anchorScore: 100,
        ).band,
        'Free',
      );
      expect(
        FinWiseScore(
          flowScore: 85,
          quadrantScore: 85,
          behaviorScore: 85,
          anchorScore: 85,
        ).band,
        'Thriving',
      );
      expect(
        FinWiseScore(
          flowScore: 70,
          quadrantScore: 70,
          behaviorScore: 70,
          anchorScore: 70,
        ).band,
        'Growing',
      );
      expect(
        FinWiseScore(
          flowScore: 50,
          quadrantScore: 50,
          behaviorScore: 50,
          anchorScore: 50,
        ).band,
        'Stable',
      );
    });
  });
}
