// Core logic for calculating available budgets, tracking expenses,
// and evaluating financial health scores in real-time.
import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../core/utils/date_utils.dart';
import 'package:home_widget/home_widget.dart';
import '../core/utils/currency_formatter.dart';
import 'income_provider.dart';
import 'transaction_provider.dart';
import 'cicilan_provider.dart';
import '../algorithms/flow_engine.dart';
import '../data/models/flow_zone.dart';
import '../data/repositories/flow_zone_repository.dart';
import '../algorithms/behavior_intelligence.dart';
import '../algorithms/quadrant_tracker.dart';
import '../algorithms/enough_anchor.dart';
import '../algorithms/finwise_score.dart';
import '../algorithms/ai_trigger_engine.dart';
import '../data/models/ai_context_package.dart';
import '../data/models/income_source.dart';
import '../data/models/ai_insight.dart';
import '../data/repositories/user_profile_repository.dart';
import 'user_profile_provider.dart';
import 'daily_limit_strategy_provider.dart';

final currentCycleProvider = Provider<Map<String, DateTime>>((ref) {
  final profile = ref.watch(userProfileProvider);
  final incomes = ref.watch(incomeProvider);
  final persistedProfile = UserProfileRepository().getProfile();
  final profileSalaryDate = profile?.salaryDate ?? persistedProfile?.salaryDate;
  final inferredIncomeSalaryDate = _inferSalaryDateFromIncome(incomes);
  final salaryDate = _resolveSalaryDate(
    profileSalaryDate: profileSalaryDate,
    inferredIncomeSalaryDate: inferredIncomeSalaryDate,
  );
  return AppDateUtils.getCycleRange(salaryDate, DateTime.now());
});

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
  final cycle = ref.watch(currentCycleProvider);
  final start = cycle['start']!;
  final end = cycle['end']!;

  return transactions
      .where(
        (t) =>
            t.type == 'expense' &&
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))),
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final totalIncomeThisMonthProvider = Provider<double>((ref) {
  final transactions = ref.watch(transactionProvider);
  final cycle = ref.watch(currentCycleProvider);
  final start = cycle['start']!;
  final end = cycle['end']!;

  return transactions
      .where(
        (t) =>
            t.type == 'income' &&
            t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1))),
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final remainingBudgetProvider = Provider<double>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  final incomeTransactions = ref.watch(totalIncomeThisMonthProvider);
  final expense = ref.watch(totalExpenseThisMonthProvider);
  return freeBudget + incomeTransactions - expense;
});

final flowZoneRepositoryProvider = Provider((ref) => FlowZoneRepository());

final flowZoneProvider = StateNotifierProvider<FlowZoneNotifier, FlowZone>((
  ref,
) {
  final repo = ref.watch(flowZoneRepositoryProvider);
  return FlowZoneNotifier(repo);
});

class FlowZoneNotifier extends StateNotifier<FlowZone> {
  final FlowZoneRepository _repo;
  FlowZoneNotifier(this._repo) : super(FlowZone()) {
    _load();
  }

  void _load() {
    _repo.init().then((_) {
      state = _repo.getFlowZone();
    });
  }

  Future<void> updateZones(FlowZone zone) async {
    await _repo.saveFlowZone(zone);
    state = zone;
  }
}

final behaviorIntelligenceProvider = Provider<BehaviorIntelligence>((ref) {
  final transactions = ref.watch(transactionProvider);
  final freeBudget = ref.watch(freeBudgetProvider);
  final cycle = ref.watch(currentCycleProvider);
  final now = DateTime.now();
  final start = cycle['start']!;
  final end = cycle['end']!;

  return BehaviorIntelligence(
    transactions: transactions
        .where(
          (t) =>
              t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(end.add(const Duration(seconds: 1))),
        )
        .toList(),
    totalFreeBudget: freeBudget,
    daysPassed: now.difference(start).inDays + 1,
    totalDaysInMonth: AppDateUtils.getDaysInCycle(start, end),
  );
});

final quadrantTrackerProvider = Provider<QuadrantTracker>((ref) {
  final incomes = ref.watch(incomeProvider);
  return QuadrantTracker(incomeSources: incomes);
});

final enoughAnchorProvider = Provider<EnoughAnchor>((ref) {
  final profile = ref.watch(userProfileProvider);
  // Future: fetch actual net worth and emergency fund from specialized providers/repos
  return EnoughAnchor(
    currentEmergencyFund: 0.0, // Mock for now
    emergencyFundTarget: profile?.emergencyFundTarget ?? 15000000,
    currentPassiveIncome: 0.0, // Mock for now
    monthlyPassiveTarget: profile?.monthlyPassiveTarget ?? 5000000,
    currentNetWorth: 0.0, // Mock for now
    netWorthTarget: profile?.netWorthTarget ?? 100000000,
  );
});

final finWiseScoreProvider = Provider<FinWiseScore>((ref) {
  final flowScore = ref.watch(flowEfficiencyScoreProvider);
  final quadrant = ref.watch(quadrantTrackerProvider);
  final behavior = ref.watch(behaviorIntelligenceProvider);
  final anchor = ref.watch(enoughAnchorProvider);

  // Calculate behavior score from components
  double impulseScore = (1.0 - behavior.impulseRateOverall) * 100;
  double assetScore = (behavior.assetToLiabilityRatio).clamp(0.0, 2.0) * 50;
  double behaviorScore = (impulseScore * 0.5) + (assetScore * 0.5);

  return FinWiseScore(
    flowScore: flowScore,
    quadrantScore: quadrant.freedomIndex,
    behaviorScore: behaviorScore,
    anchorScore: anchor.anchorScore,
  );
});

final aiContextPackageProvider = Provider<AIContextPackage>((ref) {
  final grossIncome = ref.watch(totalFixedIncomeProvider);
  final cicilan = ref.watch(currentCicilanProvider);
  final freeBudget = ref.watch(freeBudgetProvider);
  final remaining = ref.watch(remainingBudgetProvider);
  final adaptiveLimit = ref.watch(dailySafeLimitProvider);

  final engine = ref.watch(flowEngineProvider);
  final spending = ref.watch(zoneSpendingProvider);
  final quadrant = ref.watch(quadrantTrackerProvider);
  final behavior = ref.watch(behaviorIntelligenceProvider);
  final score = ref.watch(finWiseScoreProvider);
  final anchor = ref.watch(enoughAnchorProvider);

  return AIContextPackage(
    totalFixedIncome: grossIncome,
    currentCicilan: cicilan,
    freeBudget: freeBudget,
    remainingBudget: remaining,
    adaptiveDailySafeLimit: adaptiveLimit,
    zoneDistribution: spending,
    flowScore: engine.zoneEfficiencyScore,
    spendingVelocity: behavior.spendingVelocityRatio,
    incomeByQuadrant: quadrant.incomeDistribution,
    freedomIndex: quadrant.freedomIndex,
    trajectory: 'stable', // Future: calculate from historical 3 months
    spendingByDay: {}, // Future: aggregate from behavior
    impulseRateOverall: behavior.impulseRateOverall,
    assetToLiabilityRatio: behavior.assetToLiabilityRatio,
    topImpulseCategory: 'None', // Future: find top category
    currentFWS: score.compute(),
    fwsDelta: 0, // Future: compare with previous
    fwsBand: score.band,
    emergencyFundProgress: anchor.emergencyFundProgress,
    enoughAnchorScore: anchor.anchorScore,
  );
});

final aiTriggerEngineProvider = Provider<AiTriggerEngine>((ref) {
  final context = ref.watch(aiContextPackageProvider);
  return AiTriggerEngine(context);
});

final aiInsightsProvider = Provider<List<AiInsight>>((ref) {
  final engine = ref.watch(aiTriggerEngineProvider);
  return engine.generateInsights();
});

final zoneSpendingProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionProvider);
  final cycle = ref.watch(currentCycleProvider);
  final start = cycle['start']!;
  final end = cycle['end']!;

  double shield = 0, flow = 0, grow = 0, free = 0;

  for (final tx in transactions) {
    if (tx.type != 'expense' ||
        tx.date.isBefore(start) ||
        tx.date.isAfter(end)) {
      continue;
    }

    final zone = _mapCategoryToZone(tx.category);
    switch (zone) {
      case 'shield':
        shield += tx.amount;
        break;
      case 'flow':
        flow += tx.amount;
        break;
      case 'grow':
        grow += tx.amount;
        break;
      case 'free':
        free += tx.amount;
        break;
    }
  }

  return {'shield': shield, 'flow': flow, 'grow': grow, 'free': free};
});

final flowEngineProvider = Provider<FlowEngine>((ref) {
  final target = ref.watch(flowZoneProvider);
  final totalFreeBudget = ref.watch(freeBudgetProvider);
  final spending = ref.watch(zoneSpendingProvider);
  final behavior = ref.watch(behaviorIntelligenceProvider);
  final cycle = ref.watch(currentCycleProvider);
  final now = DateTime.now();
  final start = cycle['start']!;
  final end = cycle['end']!;

  return FlowEngine(
    target: target,
    totalFreeBudget: totalFreeBudget,
    spentShield: spending['shield'] ?? 0,
    spentFlow: spending['flow'] ?? 0,
    spentGrow: spending['grow'] ?? 0,
    spentFree: spending['free'] ?? 0,
    remainingDays: AppDateUtils.getRemainingDaysInCycle(now, end),
    totalDaysInMonth: AppDateUtils.getDaysInCycle(start, end),
    behaviorSpendingVelocity: behavior.spendingVelocityModifier,
  );
});

final flowEfficiencyScoreProvider = Provider<double>((ref) {
  final engine = ref.watch(flowEngineProvider);
  return engine.zoneEfficiencyScore;
});

final adaptiveDailyLimitProvider = Provider<double>((ref) {
  final engine = ref.watch(flowEngineProvider);
  return engine.adaptiveDailySafeLimit;
});

class DailyLimitProjection {
  final double dailyLimit;
  final int daysToPayday;
  final double forecastIncomeBeforePayday;
  final double forecastBudgetUntilPayday;
  final double estimatedRemainingAtPayday;

  const DailyLimitProjection({
    required this.dailyLimit,
    required this.daysToPayday,
    required this.forecastIncomeBeforePayday,
    required this.forecastBudgetUntilPayday,
    required this.estimatedRemainingAtPayday,
  });
}

final dailyLimitProjectionProvider =
    Provider.family<DailyLimitProjection, String>((ref, strategyKey) {
      final adaptiveLimit = ref.watch(adaptiveDailyLimitProvider);
      final remainingBudget = ref.watch(remainingBudgetProvider);
      final healthScore = ref.watch(healthScoreProvider);
      final cycle = ref.watch(currentCycleProvider);
      final incomes = ref.watch(incomeProvider);
      final cycleEnd = cycle['end']!;
      final preset = resolveDailyLimitStrategyPreset(strategyKey);

      return _buildDailyLimitProjection(
        adaptiveLimit: adaptiveLimit,
        remainingBudget: remainingBudget,
        healthScore: healthScore,
        strategyFactor: preset.factor,
        strategyKey: preset.key,
        now: DateTime.now(),
        cycleEnd: cycleEnd,
        incomes: incomes,
      );
    });

final dailyLimitPreviewProvider = Provider.family<double, String>((
  ref,
  strategyKey,
) {
  return ref.watch(dailyLimitProjectionProvider(strategyKey)).dailyLimit;
});

final dailySafeLimitProvider = Provider<double>((ref) {
  final strategy = ref.watch(dailyLimitStrategyProvider);
  return ref.watch(dailyLimitPreviewProvider(strategy.strategyKey));
});

DailyLimitProjection _buildDailyLimitProjection({
  required double adaptiveLimit,
  required double remainingBudget,
  required int healthScore,
  required double strategyFactor,
  required String strategyKey,
  required DateTime now,
  required DateTime cycleEnd,
  required List<IncomeSource> incomes,
}) {
  final daysToPayday = _daysUntilPayday(now, cycleEnd);
  final forecastIncome = _forecastIncomeBeforePayday(
    incomes: incomes,
    now: now,
    cycleEnd: cycleEnd,
  );
  final forecastBudget = max(0.0, remainingBudget) + forecastIncome;
  if (forecastBudget <= 0) {
    return DailyLimitProjection(
      dailyLimit: 0.0,
      daysToPayday: daysToPayday,
      forecastIncomeBeforePayday: 0.0,
      forecastBudgetUntilPayday: 0.0,
      estimatedRemainingAtPayday: 0.0,
    );
  }

  final runwayLimit = forecastBudget / daysToPayday;
  final engineeredLimit = max(0.0, adaptiveLimit * strategyFactor);

  final floorRatio = _humanFloorRatio(
    healthScore: healthScore,
    strategyKey: strategyKey,
  );
  final ceilingRatio = _humanCeilingRatio(strategyKey);

  final floorLimit = runwayLimit * floorRatio;
  final ceilingLimit = runwayLimit * ceilingRatio;

  final adjusted = max(engineeredLimit, floorLimit);
  final dailyLimit = adjusted
      .clamp(0.0, min(forecastBudget, ceilingLimit))
      .toDouble();
  final estimatedRemaining = max(
    0.0,
    forecastBudget - (dailyLimit * daysToPayday),
  );

  return DailyLimitProjection(
    dailyLimit: dailyLimit,
    daysToPayday: daysToPayday,
    forecastIncomeBeforePayday: forecastIncome,
    forecastBudgetUntilPayday: forecastBudget,
    estimatedRemainingAtPayday: estimatedRemaining,
  );
}

int _daysUntilPayday(DateTime now, DateTime cycleEnd) {
  final today = DateTime(now.year, now.month, now.day);
  final paydayEve = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);
  final days = paydayEve.difference(today).inDays + 1;
  return days <= 0 ? 1 : days;
}

double _forecastIncomeBeforePayday({
  required List<IncomeSource> incomes,
  required DateTime now,
  required DateTime cycleEnd,
}) {
  if (incomes.isEmpty) return 0.0;

  final start = DateTime(now.year, now.month, now.day);
  final end = DateTime(cycleEnd.year, cycleEnd.month, cycleEnd.day);
  if (end.isBefore(start)) return 0.0;

  final windowStartMonth = DateTime(start.year, start.month, 1);
  final windowEndMonth = DateTime(end.year, end.month, 1);

  double forecast = 0.0;

  for (final income in incomes) {
    if (!income.isActive || income.amount <= 0) continue;

    final reliability = _incomeForecastReliability(income.type);
    if (reliability <= 0) continue;

    var cursor = windowStartMonth;
    while (!cursor.isAfter(windowEndMonth)) {
      final day = _safeDayOfMonth(
        cursor.year,
        cursor.month,
        income.receivedOnDay,
      );
      final dueDate = DateTime(cursor.year, cursor.month, day);
      final isInsideWindow =
          (dueDate.isAtSameMomentAs(start) || dueDate.isAfter(start)) &&
          (dueDate.isAtSameMomentAs(end) || dueDate.isBefore(end));

      if (isInsideWindow) {
        forecast += income.amount * reliability;
        break; // Satu sumber income dihitung maksimal sekali per horizon.
      }
      cursor = DateTime(cursor.year, cursor.month + 1, 1);
    }
  }

  return forecast;
}

double _incomeForecastReliability(String type) {
  switch (type) {
    case 'fixed_monthly':
      return 1.0;
    case 'passive':
      return 0.9;
    case 'variable_monthly':
      return 0.65;
    case 'one_time':
      return 0.0; // Tidak diprediksi tanpa tanggal eksplisit.
    default:
      return 0.6;
  }
}

int _safeDayOfMonth(int year, int month, int requestedDay) {
  final lastDay = DateTime(year, month + 1, 0).day;
  return requestedDay.clamp(1, lastDay);
}

double _humanFloorRatio({
  required int healthScore,
  required String strategyKey,
}) {
  double base;
  if (healthScore >= 85) {
    base = 0.80;
  } else if (healthScore >= 70) {
    base = 0.72;
  } else if (healthScore >= 50) {
    base = 0.62;
  } else if (healthScore >= 30) {
    base = 0.52;
  } else {
    base = 0.42;
  }

  switch (strategyKey) {
    case 'conservative':
      base -= 0.10;
      break;
    case 'flexible':
      base += 0.06;
      break;
    default:
      break;
  }

  return base.clamp(0.35, 0.90);
}

double _humanCeilingRatio(String strategyKey) {
  switch (strategyKey) {
    case 'conservative':
      return 0.95;
    case 'flexible':
      return 1.20;
    default:
      return 1.05;
  }
}

// Helper for Phase 1 (will be replaced by Category model zone field in Phase 2)
String _mapCategoryToZone(String categoryName) {
  switch (categoryName) {
    case 'Kesehatan':
      return 'shield';
    case 'Makanan':
      return 'flow';
    case 'Transport':
      return 'flow';
    case 'Tagihan':
      return 'flow';
    case 'Pendidikan':
      return 'grow';
    case 'Investasi':
      return 'grow';
    case 'Hiburan':
      return 'free';
    case 'Belanja':
      return 'free';
    default:
      return 'free';
  }
}

final healthScoreProvider = Provider<int>((ref) {
  final freeBudget = ref.watch(freeBudgetProvider);
  final incomeTransactions = ref.watch(totalIncomeThisMonthProvider);
  final totalAvailable = freeBudget + incomeTransactions;

  if (totalAvailable <= 0) {
    return 0; // Prevent division by zero if no budget at all
  }

  final ratio = ref.watch(totalExpenseThisMonthProvider) / totalAvailable;
  if (ratio.isNaN || ratio.isInfinite) return 100;
  if (ratio <= 0.50) return 100;
  if (ratio <= 0.70) return 75;
  if (ratio <= 0.85) return 50;
  if (ratio <= 1.00) return 25;
  return 0; // Overspending
});

// Sync data to Android Home Widget
Future<void> _homeWidgetSyncQueue = Future<void>.value();
String? _lastWidgetPayloadSignature;

final homeWidgetSyncProvider = Provider<void>((ref) {
  final remaining = ref.watch(remainingBudgetProvider);
  final dailyLimit = ref.watch(dailySafeLimitProvider);
  final healthScore = ref.watch(healthScoreProvider);
  final cycle = ref.watch(currentCycleProvider);
  final cycleEnd = cycle['end']!;
  final daysRemaining = AppDateUtils.getRemainingDaysInCycle(
    DateTime.now(),
    cycleEnd,
  );
  final runwayDailyValue = _runwayDailyValue(
    remainingBudget: remaining,
    daysRemaining: daysRemaining,
  );

  final payloadSignature = [
    remaining.round(),
    dailyLimit.round(),
    healthScore,
    daysRemaining,
    cycleEnd.millisecondsSinceEpoch,
  ].join('|');

  if (payloadSignature == _lastWidgetPayloadSignature) {
    return;
  }
  _lastWidgetPayloadSignature = payloadSignature;

  final payload = _WidgetSyncPayload(
    remainingBudget: CurrencyFormatter.format(remaining),
    dailyLimit: CurrencyFormatter.format(dailyLimit),
    healthScore: healthScore,
    daysRemainingText: '$daysRemaining hari',
    daysRemainingValue: daysRemaining,
    healthStatus: _healthStatusLabel(healthScore),
    healthTrend: _healthTrendLabel(healthScore),
    remainingBudgetRaw: remaining,
    dailyLimitRaw: dailyLimit,
    cycleEnd: cycleEnd,
    runwayDaily: CurrencyFormatter.format(runwayDailyValue),
    runwayStatus: _runwayStatusLabel(
      remainingBudget: remaining,
      dailyLimit: dailyLimit,
      daysRemaining: daysRemaining,
      healthScore: healthScore,
    ),
    runwayHint: _runwayHintText(
      remainingBudget: remaining,
      dailyLimit: dailyLimit,
      daysRemaining: daysRemaining,
      healthScore: healthScore,
    ),
    widgetLastSync: _widgetSyncClock(DateTime.now()),
  );

  _homeWidgetSyncQueue = _homeWidgetSyncQueue
      .then((_) => _syncHomeWidgetData(payload))
      .catchError((_) {});
});

Future<void> _syncHomeWidgetData(_WidgetSyncPayload payload) async {
  if (kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android &&
      defaultTargetPlatform != TargetPlatform.iOS) {
    return;
  }

  try {
    final syncEpoch = DateTime.now().millisecondsSinceEpoch.toString();
    await HomeWidget.saveWidgetData<String>(
      'remainingBudget',
      payload.remainingBudget,
    );
    await HomeWidget.saveWidgetData<String>('dailyLimit', payload.dailyLimit);
    await HomeWidget.saveWidgetData<int>('healthScore', payload.healthScore);
    await HomeWidget.saveWidgetData<String>(
      'daysRemaining',
      payload.daysRemainingText,
    );
    await HomeWidget.saveWidgetData<String>(
      'daysRemainingValue',
      payload.daysRemainingValue.toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      'healthStatus',
      payload.healthStatus,
    );
    await HomeWidget.saveWidgetData<String>('healthTrend', payload.healthTrend);
    await HomeWidget.saveWidgetData<String>(
      'remainingBudgetRaw',
      payload.remainingBudgetRaw.round().toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      'dailyLimitRaw',
      payload.dailyLimitRaw.round().toString(),
    );
    await HomeWidget.saveWidgetData<String>(
      'cycleEndEpoch',
      payload.cycleEnd.millisecondsSinceEpoch.toString(),
    );
    await HomeWidget.saveWidgetData<String>('runwayDaily', payload.runwayDaily);
    await HomeWidget.saveWidgetData<String>(
      'runwayStatus',
      payload.runwayStatus,
    );
    await HomeWidget.saveWidgetData<String>('runwayHint', payload.runwayHint);
    await HomeWidget.saveWidgetData<String>(
      'widgetLastSync',
      payload.widgetLastSync,
    );
    await HomeWidget.saveWidgetData<String>('widgetSyncEpoch', syncEpoch);

    await HomeWidget.updateWidget(
      name: 'DashboardWidgetProvider',
      iOSName: 'DashboardWidget',
    );
    await HomeWidget.updateWidget(
      name: 'HealthSnapshotWidgetProvider',
      iOSName: 'HealthSnapshotWidget',
    );
    await HomeWidget.updateWidget(
      name: 'RunwayWidgetProvider',
      iOSName: 'RunwayWidget',
    );
  } on MissingPluginException {
    // Plugin may be unavailable in some runtime contexts (e.g. hot restart).
  } catch (_) {
    // Intentionally ignore non-critical widget sync failures.
  }
}

double _runwayDailyValue({
  required double remainingBudget,
  required int daysRemaining,
}) {
  final safeDays = daysRemaining <= 0 ? 1 : daysRemaining;
  return remainingBudget / safeDays;
}

String _runwayStatusLabel({
  required double remainingBudget,
  required double dailyLimit,
  required int daysRemaining,
  required int healthScore,
}) {
  if (remainingBudget <= 0 || dailyLimit <= 0 || healthScore < 50) {
    return 'KRITIS';
  }

  final runwayDaily = _runwayDailyValue(
    remainingBudget: remainingBudget,
    daysRemaining: daysRemaining,
  );
  if (healthScore < 70 || runwayDaily < (dailyLimit * 0.9)) {
    return 'WASPADA';
  }
  return 'AMAN';
}

String _runwayHintText({
  required double remainingBudget,
  required double dailyLimit,
  required int daysRemaining,
  required int healthScore,
}) {
  final status = _runwayStatusLabel(
    remainingBudget: remainingBudget,
    dailyLimit: dailyLimit,
    daysRemaining: daysRemaining,
    healthScore: healthScore,
  );

  switch (status) {
    case 'KRITIS':
      return 'Tahan belanja non-esensial hari ini.';
    case 'WASPADA':
      return 'Patuhi limit ${CurrencyFormatter.format(dailyLimit)}.';
    default:
      return 'Ritme aman, tetap disiplin.';
  }
}

String _widgetSyncClock(DateTime value) {
  final hh = value.hour.toString().padLeft(2, '0');
  final mm = value.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class _WidgetSyncPayload {
  final String remainingBudget;
  final String dailyLimit;
  final int healthScore;
  final String daysRemainingText;
  final int daysRemainingValue;
  final String healthStatus;
  final String healthTrend;
  final double remainingBudgetRaw;
  final double dailyLimitRaw;
  final DateTime cycleEnd;
  final String runwayDaily;
  final String runwayStatus;
  final String runwayHint;
  final String widgetLastSync;

  const _WidgetSyncPayload({
    required this.remainingBudget,
    required this.dailyLimit,
    required this.healthScore,
    required this.daysRemainingText,
    required this.daysRemainingValue,
    required this.healthStatus,
    required this.healthTrend,
    required this.remainingBudgetRaw,
    required this.dailyLimitRaw,
    required this.cycleEnd,
    required this.runwayDaily,
    required this.runwayStatus,
    required this.runwayHint,
    required this.widgetLastSync,
  });
}

String _healthStatusLabel(int healthScore) {
  if (healthScore >= 90) return 'Aman';
  if (healthScore >= 70) return 'Stabil';
  if (healthScore >= 50) return 'Waspada';
  return 'Rawan';
}

String _healthTrendLabel(int healthScore) {
  if (healthScore >= 90) return 'Efisien';
  if (healthScore >= 70) return 'Terkontrol';
  if (healthScore >= 50) return 'Jaga laju';
  return 'Rem belanja';
}

int? _inferSalaryDateFromIncome(List<IncomeSource> incomes) {
  final candidates =
      incomes
          .where((i) => i.isActive && i.type == 'fixed_monthly')
          .map((i) => i.receivedOnDay)
          .where((d) => d >= 1 && d <= 31)
          .toList()
        ..sort();
  if (candidates.isEmpty) return null;
  return candidates.first;
}

int _resolveSalaryDate({
  required int? profileSalaryDate,
  required int? inferredIncomeSalaryDate,
}) {
  if (profileSalaryDate == null) {
    return inferredIncomeSalaryDate ?? 25;
  }

  // Legacy profile often carries default 25. If income sources clearly indicate
  // another received day, use that for cycle/widget calculation.
  if (profileSalaryDate == 25 &&
      inferredIncomeSalaryDate != null &&
      inferredIncomeSalaryDate != 25) {
    return inferredIncomeSalaryDate;
  }

  return profileSalaryDate.clamp(1, 31);
}
