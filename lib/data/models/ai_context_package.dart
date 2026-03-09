class AIContextPackage {
  // === REAL-TIME ===
  final double totalFixedIncome;
  final double currentCicilan;
  final double freeBudget;
  final double remainingBudget;
  final double adaptiveDailySafeLimit;

  // === FLOW ENGINE ===
  final Map<String, double> zoneDistribution;
  final double flowScore;
  final double spendingVelocity;

  // === QUADRANT ===
  final Map<String, double> incomeByQuadrant;
  final double freedomIndex;
  final String trajectory;

  // === BEHAVIOR ===
  final Map<int, double> spendingByDay;
  final double impulseRateOverall;
  final double assetToLiabilityRatio;
  final String topImpulseCategory;

  // === FWS ===
  final double currentFWS;
  final double fwsDelta;
  final String fwsBand;

  // === ANCHOR ===
  final double emergencyFundProgress;
  final double enoughAnchorScore;

  AIContextPackage({
    required this.totalFixedIncome,
    required this.currentCicilan,
    required this.freeBudget,
    required this.remainingBudget,
    required this.adaptiveDailySafeLimit,
    required this.zoneDistribution,
    required this.flowScore,
    required this.spendingVelocity,
    required this.incomeByQuadrant,
    required this.freedomIndex,
    required this.trajectory,
    required this.spendingByDay,
    required this.impulseRateOverall,
    required this.assetToLiabilityRatio,
    required this.topImpulseCategory,
    required this.currentFWS,
    required this.fwsDelta,
    required this.fwsBand,
    required this.emergencyFundProgress,
    required this.enoughAnchorScore,
  });
}
