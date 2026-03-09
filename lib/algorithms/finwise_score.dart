class FinWiseScore {
  final double flowScore; // 0-100 (from FlowEngine)
  final double quadrantScore; // 0-100 (from QuadrantTracker)
  final double behaviorScore; // 0-100 (from BehaviorIntelligence)
  final double anchorScore; // 0-100 (from EnoughAnchor)

  static const double FLOW_WEIGHT = 0.30;
  static const double QUADRANT_WEIGHT = 0.25;
  static const double BEHAVIOR_WEIGHT = 0.25;
  static const double ANCHOR_WEIGHT = 0.20;

  FinWiseScore({
    required this.flowScore,
    required this.quadrantScore,
    required this.behaviorScore,
    required this.anchorScore,
  });

  double compute() {
    double raw =
        (flowScore * FLOW_WEIGHT) +
        (quadrantScore * QUADRANT_WEIGHT) +
        (behaviorScore * BEHAVIOR_WEIGHT) +
        (anchorScore * ANCHOR_WEIGHT);

    // Scale to 0-1000
    return raw * 10;
  }

  String get band {
    double score = compute();
    if (score < 200) return 'Fragile';
    if (score < 400) return 'Surviving';
    if (score < 600) return 'Stable';
    if (score < 800) return 'Growing';
    if (score < 900) return 'Thriving';
    return 'Free';
  }

  String get bandColor {
    double score = compute();
    if (score < 200) return '#A33030';
    if (score < 400) return '#B07D2E';
    if (score < 600) return '#2D5186';
    if (score < 800) return '#3D7A5E';
    if (score < 900) return '#1E3A5F';
    return '#0D5C3A';
  }
}
