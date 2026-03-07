import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/budget_provider.dart';
import '../../../data/repositories/user_profile_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(healthScoreProvider);
    final freeBudget = ref.watch(freeBudgetProvider);
    final expense = ref.watch(totalExpenseThisMonthProvider);
    final remaining = ref.watch(remainingBudgetProvider);
    final dailyLimit = ref.watch(dailySafeLimitProvider);
    final cicilan = ref.watch(currentCicilanProvider);

    final profile = UserProfileRepository().getProfile();
    final name = profile?.name ?? 'User';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, $name!',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        'Ringkasan Keuangan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryMuted,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Health Score Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: healthScore >= 75
                              ? AppColors.successBg
                              : (healthScore >= 50
                                    ? AppColors.warningBg
                                    : AppColors.dangerBg),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.activity,
                          color: healthScore >= 75
                              ? AppColors.success
                              : (healthScore >= 50
                                    ? AppColors.warning
                                    : AppColors.danger),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Health Score',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$healthScore/100',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: healthScore >= 75
                                    ? AppColors.success
                                    : (healthScore >= 50
                                          ? AppColors.warning
                                          : AppColors.danger),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Meter
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tersisa Bulan Ini',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CurrencyFormatter.format(remaining),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'JetBrainsMono',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: Stack(
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 70,
                                startDegreeOffset: -90,
                                sections: [
                                  PieChartSectionData(
                                    color: AppColors.primary,
                                    value: expense > 0
                                        ? expense
                                        : 0.1, // Prevent invisible section
                                    title: '',
                                    radius: 20,
                                  ),
                                  PieChartSectionData(
                                    color: AppColors.primaryMuted,
                                    value: remaining > 0 ? remaining : 0.1,
                                    title: '',
                                    radius: 20,
                                  ),
                                ],
                              ),
                              swapAnimationDuration: const Duration(
                                milliseconds: 500,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Terpakai',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(expense),
                                    style: const TextStyle(
                                      fontFamily: 'JetBrainsMono',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Budget Bebas',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          Text(
                            CurrencyFormatter.format(freeBudget),
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daily Limit & Cicilan
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Batas Harian (Aman)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(dailyLimit),
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cicilan Wajib',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(cicilan),
                              style: const TextStyle(
                                fontFamily: 'JetBrainsMono',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Add
              ElevatedButton.icon(
                onPressed: () {
                  // Open quick add bottom sheet
                },
                icon: const Icon(LucideIcons.plusCircle, color: Colors.white),
                label: const Text(
                  'Catat Pengeluaran',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
