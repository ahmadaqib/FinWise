import 'dart:math';
import '../data/models/flow_zone.dart';

class FlowEngine {
  final FlowZone target;
  final double totalFreeBudget;
  final double spentShield;
  final double spentFlow;
  final double spentGrow;
  final double spentFree;
  final int remainingDays;
  final int totalDaysInMonth;
  final double behaviorSpendingVelocity; // modifier from Layer 3

  FlowEngine({
    required this.target,
    required this.totalFreeBudget,
    required this.spentShield,
    required this.spentFlow,
    required this.spentGrow,
    required this.spentFree,
    required this.remainingDays,
    required this.totalDaysInMonth,
    this.behaviorSpendingVelocity = 1.0,
  });

  // Target amounts based on percentages
  double get targetShield => totalFreeBudget * (target.shieldTarget / 100);
  double get targetFlow => totalFreeBudget * (target.flowTarget / 100);
  double get targetGrow => totalFreeBudget * (target.growTarget / 100);
  double get targetFree => totalFreeBudget * (target.freeTarget / 100);

  // Efficiency score (0-100)
  double get zoneEfficiencyScore {
    double shieldScore = _calculateZoneScore(spentShield, targetShield);
    double flowScore = _calculateZoneScore(spentFlow, targetFlow);
    double growScore = _calculateZoneScore(spentGrow, targetGrow);
    double freeScore = _calculateZoneScore(spentFree, targetFree);

    // GROW given higher weight (35%) as it's the indicator of long-term progress
    return (shieldScore * 0.25) +
        (flowScore * 0.25) +
        (growScore * 0.35) +
        (freeScore * 0.15);
  }

  double _calculateZoneScore(double actual, double target) {
    if (target <= 0) return 100;
    // For Shield and Grow: higher/equal is better
    // For Flow and Free: lower is better (staying within budget)
    // However, the PRD just says _zoneScore(actual, target)
    // Let's assume it measures how close we are to the budget.
    double ratio = actual / target;
    if (ratio <= 1.0) return 100;
    return max(0, 100 - (ratio - 1.0) * 100);
  }

  // Adaptive Daily Safe Limit
  double get adaptiveDailySafeLimit {
    double remainingBudget =
        totalFreeBudget - (spentShield + spentFlow + spentGrow + spentFree);
    if (remainingBudget <= 0) return 0.0;
    if (remainingDays <= 0) return remainingBudget;

    double baseLimit = remainingBudget / remainingDays;
    double proximityMod = _cycleProximityModifier();
    double limit = baseLimit * behaviorSpendingVelocity * proximityMod;
    return max(0.0, limit);
  }

  double _cycleProximityModifier() {
    double remainingDaysRatio = remainingDays / totalDaysInMonth;
    double currentRemainingBudget =
        totalFreeBudget - (spentShield + spentFlow + spentGrow + spentFree);
    double budgetRatio = currentRemainingBudget / totalFreeBudget;

    if (budgetRatio < remainingDaysRatio && remainingDaysRatio > 0) {
      // Money is being spent faster than time is passing - auto-brake
      return budgetRatio / remainingDaysRatio;
    }
    return 1.0;
  }
}
