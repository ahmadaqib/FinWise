import '../data/models/income_source.dart';

class QuadrantTracker {
  final List<IncomeSource> incomeSources;

  QuadrantTracker({required this.incomeSources});

  // Income Distribution per Quadrant
  Map<String, double> get incomeDistribution {
    final dist = <String, double>{'E': 0, 'S': 0, 'B': 0, 'I': 0};
    for (var source in incomeSources.where((s) => s.isActive)) {
      dist[source.quadrant] = (dist[source.quadrant] ?? 0) + source.amount;
    }
    return dist;
  }

  // Freedom Index (0-100)
  double get freedomIndex {
    double total = incomeSources
        .where((s) => s.isActive)
        .fold(0.0, (sum, s) => sum + s.amount);
    if (total <= 0) return 0.0;

    final dist = incomeDistribution;

    // Weights based on PRD: E: 0.0, S: 0.25, B: 0.75, I: 1.0
    double eWeight = 0.0;
    double sWeight = 0.25;
    double bWeight = 0.75;
    double iWeight = 1.0;

    return ((dist['E']! * eWeight) +
            (dist['S']! * sWeight) +
            (dist['B']! * bWeight) +
            (dist['I']! * iWeight)) /
        total *
        100;
  }

  // Milestone Detection
  String? get currentMilestone {
    final index = freedomIndex;
    final dist = incomeDistribution;

    if (index >= 100) return 'full_freedom';
    if (dist['B']! + dist['I']! > dist['E']! + dist['S']!)
      return 'crossover_point';
    if (index >= 50) return 'half_free';
    if (dist['I']! > 0) return 'investor_born';
    if (index >= 25) return 'quarter_free';
    if (dist['S']! > 0) return 'first_s_income';
    if (index == 0) return 'starting_point';
    return null;
  }
}
