import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/enough_anchor.dart';

void main() {
  group('EnoughAnchor Tests', () {
    test('Progress capped at 100% when exceeding target', () {
      final anchor = EnoughAnchor(
        currentEmergencyFund: 200,
        emergencyFundTarget: 100,
        currentPassiveIncome: 50,
        monthlyPassiveTarget: 100,
        currentNetWorth: 0,
        netWorthTarget: 100,
      );

      expect(anchor.emergencyFundProgress, 100.0);
    });

    test('Division by zero when target = 0 returns 100', () {
      final anchor = EnoughAnchor(
        currentEmergencyFund: 0,
        emergencyFundTarget: 0,
        currentPassiveIncome: 0,
        monthlyPassiveTarget: 0,
        currentNetWorth: 0,
        netWorthTarget: 0,
      );

      expect(anchor.emergencyFundProgress, 100.0);
      expect(anchor.passiveIncomeProgress, 100.0);
    });

    test('Weighted anchor score reflects 50/30/20 split', () {
      // 100% EF (50), 0% others
      final anchor = EnoughAnchor(
        currentEmergencyFund: 100,
        emergencyFundTarget: 100,
        currentPassiveIncome: 0,
        monthlyPassiveTarget: 100,
        currentNetWorth: 0,
        netWorthTarget: 100,
      );

      expect(anchor.anchorScore, 50.0);
    });
  });
}
