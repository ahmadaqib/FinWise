import 'dart:math';

class EnoughAnchor {
  final double currentEmergencyFund;
  final double emergencyFundTarget;
  final double currentPassiveIncome;
  final double monthlyPassiveTarget;
  final double currentNetWorth;
  final double netWorthTarget;

  EnoughAnchor({
    required this.currentEmergencyFund,
    required this.emergencyFundTarget,
    required this.currentPassiveIncome,
    required this.monthlyPassiveTarget,
    required this.currentNetWorth,
    required this.netWorthTarget,
  });

  double get emergencyFundProgress => emergencyFundTarget > 0
      ? min(1.0, currentEmergencyFund / emergencyFundTarget) * 100
      : 100;

  double get passiveIncomeProgress => monthlyPassiveTarget > 0
      ? min(1.0, currentPassiveIncome / monthlyPassiveTarget) * 100
      : 100;

  double get netWorthProgress => netWorthTarget > 0
      ? min(1.0, currentNetWorth / netWorthTarget) * 100
      : 100;

  double get anchorScore {
    // Weighted score: 50% Emergency Fund, 30% Passive Income, 20% Net Worth
    return (emergencyFundProgress * 0.5) +
        (passiveIncomeProgress * 0.3) +
        (netWorthProgress * 0.2);
  }
}
