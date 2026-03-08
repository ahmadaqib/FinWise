import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../core/utils/date_utils.dart';
import 'package:home_widget/home_widget.dart';
import '../core/utils/currency_formatter.dart';
import 'income_provider.dart';
import 'transaction_provider.dart';
import 'cicilan_provider.dart';

final totalFixedIncomeProvider = Provider<double>((ref) {
  final incomes = ref.watch(incomeProvider);
  return incomes
      .where(
        (s) => s.isActive && (s.type == 'fixed_monthly' || s.type == 'passive'),
      )
      .fold(0.0, (sum, s) => sum + s.amount);
});

final currentCicilanProvider = Provider<double>((ref) {
  return ref.watch(totalCicilanThisMonthProvider);
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

final totalIncomeThisMonthProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  final now = DateTime.now();
  return transactions
      .where(
        (t) =>
            t.type == 'income' &&
            t.date.year == now.year &&
            t.date.month == now.month,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final remainingBudgetProvider = Provider<double>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  final incomeTransactions = ref.watch(totalIncomeThisMonthProvider);
  final expense = ref.watch(totalExpenseThisMonthProvider);
  return freeBudget + incomeTransactions - expense;
});

final dailySafeLimitProvider = Provider<double>((ref) {
  final remaining = ref.watch(remainingBudgetProvider);
  final daysRemaining = AppDateUtils.getRemainingDaysInMonth(DateTime.now());
  if (daysRemaining <= 0) return remaining;
  return remaining / daysRemaining;
});

final healthScoreProvider = Provider<int>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  final incomeTransactions = ref.watch(totalIncomeThisMonthProvider);
  final totalAvailable = freeBudget + incomeTransactions;

  if (totalAvailable <= 0)
    return 0; // Prevent division by zero if no budget at all

  final ratio = ref.watch(totalExpenseThisMonthProvider) / totalAvailable;
  if (ratio.isNaN || ratio.isInfinite) return 100;
  if (ratio <= 0.50) return 100;
  if (ratio <= 0.70) return 75;
  if (ratio <= 0.85) return 50;
  if (ratio <= 1.00) return 25;
  return 0; // Overspending
});

// Sync data to Android Home Widget
final homeWidgetSyncProvider = Provider<void>((ref) {
  final remaining = ref.watch(remainingBudgetProvider);
  final dailyLimit = ref.watch(dailySafeLimitProvider);

  unawaited(
    _syncHomeWidgetData(
      remainingBudget: CurrencyFormatter.format(remaining),
      dailyLimit: CurrencyFormatter.format(dailyLimit),
    ),
  );
});

Future<void> _syncHomeWidgetData({
  required String remainingBudget,
  required String dailyLimit,
}) async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  try {
    await HomeWidget.saveWidgetData<String>('remainingBudget', remainingBudget);
    await HomeWidget.saveWidgetData<String>('dailyLimit', dailyLimit);
    await HomeWidget.updateWidget(
      name: 'DashboardWidgetProvider',
      iOSName: 'DashboardWidget',
    );
  } on MissingPluginException {
    // Plugin may be unavailable in some runtime contexts (e.g. hot restart).
  } catch (_) {
    // Intentionally ignore non-critical widget sync failures.
  }
}
