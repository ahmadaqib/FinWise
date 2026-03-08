import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/daily_insight_provider.dart';
import '../../../providers/cicilan_provider.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../transactions/widgets/transaction_form.dart';

// Dashboard Widgets
import '../widgets/greeting_header.dart';
import '../widgets/health_score_section.dart';
import '../widgets/key_metrics_row.dart';
import '../widgets/budget_meter_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/cicilan_status_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(healthScoreProvider);
    final freeBudget = ref.watch(freeBudgetProvider);
    final incomeTransactions = ref.watch(totalIncomeThisMonthProvider);
    final expense = ref.watch(totalExpenseThisMonthProvider);
    final remaining = ref.watch(remainingBudgetProvider);
    final dailyLimit = ref.watch(dailySafeLimitProvider);
    final insightAsync = ref.watch(dailyInsightProvider);

    final totalAvailable = freeBudget + incomeTransactions;

    // Watch home widget sync provider so it automatically triggers on change
    ref.watch(homeWidgetSyncProvider);

    final profile = UserProfileRepository().getProfile();
    final name = profile?.name ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GreetingHeader(name: name),

              const SizedBox(height: AppSpacing.xxl),

              HealthScoreSection(score: healthScore),

              const SizedBox(height: AppSpacing.xl),

              KeyMetricsRow(remainingBudget: remaining, dailyLimit: dailyLimit),

              const SizedBox(height: AppSpacing.lg),

              BudgetMeterCard(
                expense: expense,
                remaining: remaining > 0 ? remaining : 0,
                totalBudget: totalAvailable,
              ),

              const SizedBox(height: AppSpacing.lg),

              insightAsync.when(
                data: (insight) => InsightCard(
                  insight:
                      insight ??
                      'Belum ada insight. Catat pengeluaranmu hari ini!',
                ),
                loading: () =>
                    const InsightCard(insight: 'Menganalisis keuanganmu...'),
                error: (_, _) =>
                    const InsightCard(insight: 'Gagal memuat insight.'),
              ),

              const SizedBox(height: AppSpacing.lg),

              Consumer(
                builder: (context, ref, child) {
                  final activeCicilans = ref.watch(cicilanListProvider);

                  if (activeCicilans.isEmpty) {
                    return const SizedBox.shrink(); // Hide if no cicilan
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: activeCicilans.map((c) {
                      final paidCount = ref.watch(
                        cicilanPaidCountProvider(c.id),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: CicilanStatusCard(
                          cicilan: c,
                          paidCount: paidCount,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xxl),

              ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const TransactionForm(),
                  );
                },
                icon: const Icon(LucideIcons.plusCircle, color: Colors.white),
                label: const Text('Catat Pengeluaran'),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
