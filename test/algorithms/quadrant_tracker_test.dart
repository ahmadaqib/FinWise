import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/quadrant_tracker.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('QuadrantTracker Tests', () {
    test('Income distribution sums correctly per quadrant', () {
      final tracker = QuadrantTracker(
        incomeSources: [
          TestFixtures.mockIncome(amount: 1000, quadrant: 'E'),
          TestFixtures.mockIncome(amount: 500, quadrant: 'E'),
          TestFixtures.mockIncome(amount: 2000, quadrant: 'I'),
        ],
      );

      final dist = tracker.incomeDistribution;
      expect(dist['E'], 1500.0);
      expect(dist['I'], 2000.0);
      expect(dist['S'], 0.0);
      expect(dist['B'], 0.0);
    });

    test('Freedom Index calculation with weights', () {
      final tracker = QuadrantTracker(
        incomeSources: [
          TestFixtures.mockIncome(amount: 5000, quadrant: 'E'), // Weight 0.0
          TestFixtures.mockIncome(amount: 5000, quadrant: 'I'), // Weight 1.0
        ],
      );

      // total = 10000
      // contribution = (5000 * 0) + (5000 * 1.0) = 5000
      // index = 5000 / 10000 * 100 = 50.0
      expect(tracker.freedomIndex, 50.0);
    });

    test('Inactive sources are excluded from calculation', () {
      final tracker = QuadrantTracker(
        incomeSources: [
          TestFixtures.mockIncome(amount: 1000, quadrant: 'I', isActive: true),
          TestFixtures.mockIncome(amount: 1000, quadrant: 'I', isActive: false),
        ],
      );

      expect(tracker.freedomIndex, 100.0);
    });

    test('Milestone detection priority', () {
      final tracker1 = QuadrantTracker(
        incomeSources: [TestFixtures.mockIncome(amount: 1000, quadrant: 'E')],
      );
      expect(tracker1.currentMilestone, 'starting_point');

      final tracker2 = QuadrantTracker(
        incomeSources: [TestFixtures.mockIncome(amount: 1000, quadrant: 'I')],
      );
      expect(tracker2.currentMilestone, 'full_freedom');
    });
  });
}
