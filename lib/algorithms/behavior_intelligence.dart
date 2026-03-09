import '../data/models/transaction.dart';

class BehaviorIntelligence {
  final List<Transaction> transactions;
  final double totalFreeBudget;
  final int daysPassed;
  final int totalDaysInMonth;

  BehaviorIntelligence({
    required this.transactions,
    required this.totalFreeBudget,
    required this.daysPassed,
    required this.totalDaysInMonth,
  });

  // Spending Velocity: actual daily rate vs ideal
  double get spendingVelocityModifier {
    if (daysPassed <= 0 || totalFreeBudget <= 0) return 1.0;

    double idealDailyRate = totalFreeBudget / totalDaysInMonth;
    double totalSpent = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);

    double actualDailyRate = totalSpent / daysPassed;
    if (actualDailyRate == 0)
      return 1.1; // spending slower is good, but cap it?

    double ratio = actualDailyRate / idealDailyRate;
    // If ratio is 1.2 (20% overspending velocity), modifier is 1/1.2 = 0.83 (reduce limit)
    return 1 / ratio;
  }

  // Impulse rate: ratio of 'impulsive' mood transactions
  double get impulseRateOverall {
    final expenses = transactions.where((t) => t.type == 'expense').toList();
    if (expenses.isEmpty) return 0.0;

    final impulsive = expenses
        .where((t) => t.spendingMood == 'impulsive')
        .length;
    return impulsive / expenses.length;
  }

  // Asset vs Liability ratio
  double get assetToLiabilityRatio {
    double assetSpend = transactions
        .where(
          (t) =>
              t.transactionNature == 'asset' ||
              t.transactionNature == 'investment',
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    double liabilitySpend = transactions
        .where((t) => t.transactionNature == 'liability')
        .fold(0.0, (sum, t) => sum + t.amount);

    if (liabilitySpend == 0)
      return assetSpend > 0 ? 10.0 : 1.0; // Avoid infinity
    return assetSpend / liabilitySpend;
  }

  // Payday effect check
  bool get hasPaydayEffect {
    // Week 1 vs Week 4 spending
    double week1 = _avgSpendingByWeek(1);
    double week4 = _avgSpendingByWeek(4);

    if (week4 == 0) return week1 > 0;
    return week1 > week4 * 1.4;
  }

  double _avgSpendingByWeek(int weekNum) {
    // Simplified logic for month-based week
    final weekTxs = transactions.where((t) {
      int day = t.date.day;
      int w = ((day - 1) / 7).floor() + 1;
      return w == weekNum && t.type == 'expense';
    });

    if (weekTxs.isEmpty) return 0.0;
    return weekTxs.fold(0.0, (sum, t) => sum + t.amount) / 7;
  }
}
