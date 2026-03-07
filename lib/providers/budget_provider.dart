import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/user_profile_repository.dart';
import '../core/utils/date_utils.dart';
import 'income_provider.dart';
import 'transaction_provider.dart';

final totalFixedIncomeProvider = Provider<double>((ref) {
  final incomes = ref.watch(incomeProvider);
  return incomes
      .where(
        (s) => s.isActive && (s.type == 'fixed_monthly' || s.type == 'passive'),
      )
      .fold(0.0, (sum, s) => sum + s.amount);
});

final currentCicilanProvider = Provider<double>((ref) {
  final profile = UserProfileRepository().getProfile();
  if (profile == null) return 0.0;
  return profile.isMonth1 ? profile.cicilanMonth1 : profile.cicilanNormal;
});

final freeBudgetProvider = Provider<double>((ref) {
  final totalIncome = ref.watch(totalFixedIncomeProvider);
  final cicilan = ref.watch(currentCicilanProvider);
  return totalIncome - cicilan;
});

final totalExpenseThisMonthProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  return transactions
      .where(
        (t) =>
            t.type == 'expense' &&
            t.date.year == now.year &&
            t.date.month == now.month,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final remainingBudgetProvider = Provider<double>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  final expense = ref.watch(totalExpenseThisMonthProvider);
  return freeBudget - expense;
});

final dailySafeLimitProvider = Provider<double>((ref) {
  final remaining = ref.watch(remainingBudgetProvider);
  final daysRemaining = AppDateUtils.getRemainingDaysInMonth(DateTime.now());
  if (daysRemaining <= 0) return remaining;
  return remaining / daysRemaining;
});

final healthScoreProvider = Provider<int>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  if (freeBudget <= 0) return 0; // Prevent division by zero if no free budget

  final ratio = ref.watch(totalExpenseThisMonthProvider) / freeBudget;
  if (ratio.isNaN || ratio.isInfinite) return 100;
  if (ratio <= 0.50) return 100;
  if (ratio <= 0.70) return 75;
  if (ratio <= 0.85) return 50;
  if (ratio <= 1.00) return 25;
  return 0; // Overspending
});
