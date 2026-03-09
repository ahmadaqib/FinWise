import 'package:FinWise/data/models/flow_zone.dart';
import 'package:FinWise/data/models/transaction.dart';
import 'package:FinWise/data/models/income_source.dart';
import 'package:FinWise/data/models/ai_context_package.dart';

class TestFixtures {
  static FlowZone defaultFlowZone() => FlowZone(
    shieldTarget: 30,
    flowTarget: 30,
    growTarget: 30,
    freeTarget: 10,
  );

  static Transaction mockExpense({
    required double amount,
    String? category,
    String? spendingMood,
    String? transactionNature,
    DateTime? date,
  }) => Transaction(
    id: 'tx_${amount}_${date?.millisecondsSinceEpoch ?? 0}',
    amount: amount,
    type: 'expense',
    category: category ?? 'Food',
    date: date ?? DateTime.now(),
    spendingMood: spendingMood,
    transactionNature: transactionNature,
  );

  static IncomeSource mockIncome({
    required double amount,
    required String quadrant,
    bool isActive = true,
    int? receivedOnDay,
    DateTime? createdAt,
  }) => IncomeSource(
    id: 'inc_${amount}_$quadrant',
    name: 'Income $quadrant',
    amount: amount,
    type: 'fixed_monthly',
    quadrant: quadrant,
    isActive: isActive,
    receivedOnDay: receivedOnDay ?? 1,
    createdAt: createdAt ?? DateTime.now(),
  );

  static AIContextPackage mockAIContext({
    double spendingVelocity = 1.0,
    double freedomIndex = 0.0,
    double currentFWS = 500.0,
    double freeBudget = 1000000.0,
    Map<String, double>? zoneDistribution,
  }) => AIContextPackage(
    totalFixedIncome: 5000000,
    currentCicilan: 0,
    freeBudget: freeBudget,
    remainingBudget: freeBudget,
    adaptiveDailySafeLimit: 100000,
    zoneDistribution: zoneDistribution ?? {},
    flowScore: 100,
    spendingVelocity: spendingVelocity,
    incomeByQuadrant: {},
    freedomIndex: freedomIndex,
    trajectory: 'stable',
    spendingByDay: {},
    impulseRateOverall: 0.1,
    assetToLiabilityRatio: 1.0,
    topImpulseCategory: 'None',
    currentFWS: currentFWS,
    fwsDelta: 0,
    fwsBand: 'Stable',
    emergencyFundProgress: 0,
    enoughAnchorScore: 0,
  );
}
