import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/transaction_provider.dart';
import '../../../providers/report_filter_provider.dart';
import '../../../providers/budget_provider.dart';
import '../../../providers/cicilan_provider.dart';
import '../../../providers/nav_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/pdf_export_service.dart';
import '../../../shared/widgets/japandi_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseIncome = ref.watch(totalFixedIncomeProvider);
    final baseCicilan = ref.watch(totalCicilanThisMonthProvider);

    final monthlyTransactions = transactions
        .where(
          (t) =>
              t.date.year == selectedMonth.year &&
              t.date.month == selectedMonth.month,
        )
        .toList();

    final expenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .toList();
    final incomes = monthlyTransactions
        .where((t) => t.type == 'income')
        .toList();

    final totalExpense =
        expenses.fold(0.0, (sum, t) => sum + t.amount) + baseCicilan;
    final totalIncome =
        incomes.fold(0.0, (sum, t) => sum + t.amount) + baseIncome;
    final netBalance = totalIncome - totalExpense;

    // Group expenses by category
    final Map<String, double> expenseCats = {};
    for (var t in expenses) {
      expenseCats[t.category] = (expenseCats[t.category] ?? 0) + t.amount;
    }
    if (baseCicilan > 0) {
      expenseCats['Cicilan Bulanan'] = baseCicilan;
    }

    // Group incomes by category
    final Map<String, double> incomeCats = {};
    for (var t in incomes) {
      final cat = t.category.isEmpty ? 'Pemasukan' : t.category;
      incomeCats[cat] = (incomeCats[cat] ?? 0) + t.amount;
    }
    if (baseIncome > 0) {
      incomeCats['Pemasukan Tetap'] = baseIncome;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        automaticallyImplyLeading: false,
      ),
      body: monthlyTransactions.isEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _buildMonthSelector(context, ref, transactions),
                ),
                Expanded(
                  child: EmptyState(
                    icon: LucideIcons.pieChart,
                    title: 'Belum ada data laporan',
                    description:
                        'Catat transaksi pertamamu bulan ini untuk melihat analisanya di sini.',
                    actionLabel: 'Kembali ke Beranda',
                    onAction: () =>
                        ref.read(navIndexProvider.notifier).state = 0,
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMonthSelector(context, ref, transactions),
                  const SizedBox(height: AppSpacing.xl),

                  // Net balance hero
                  _buildNetBalanceHero(context, netBalance, isDark),
                  const SizedBox(height: AppSpacing.lg),

                  // Income vs Expense comparison
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pemasukan',
                          amount: totalIncome,
                          color: isDark
                              ? const Color(0xFF6EDC98)
                              : AppColors.success,
                          iconBg: isDark
                              ? AppColors.darkSuccessBg
                              : AppColors.successBg,
                          icon: LucideIcons.arrowDownLeft,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Pengeluaran',
                          amount: totalExpense,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : AppColors.danger,
                          iconBg: isDark
                              ? AppColors.darkDangerBg
                              : AppColors.dangerBg,
                          icon: LucideIcons.arrowUpRight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Expense chart
                  if (expenseCats.isNotEmpty) ...[
                    _ChartCard(
                      title: 'Struktur Pengeluaran',
                      categoryTotals: expenseCats,
                      total: totalExpense,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader(title: 'Rincian Pengeluaran'),
                    const SizedBox(height: AppSpacing.md),
                    ...expenseCats.entries.map(
                      (e) => _CategoryBreakdownRow(
                        category: e.key,
                        amount: e.value,
                        total: totalExpense,
                        baseColor: isDark
                            ? const Color(0xFFFCA5A5)
                            : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Income chart
                  if (incomeCats.isNotEmpty) ...[
                    _ChartCard(
                      title: 'Sumber Pemasukan',
                      categoryTotals: incomeCats,
                      total: totalIncome,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader(title: 'Rincian Pemasukan'),
                    const SizedBox(height: AppSpacing.md),
                    ...incomeCats.entries.map(
                      (e) => _CategoryBreakdownRow(
                        category: e.key,
                        amount: e.value,
                        total: totalIncome,
                        baseColor: isDark
                            ? const Color(0xFF6EDC98)
                            : AppColors.success,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  // Export Button
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final file =
                            await PdfExportService.generateMonthlyReport(
                              selectedMonth.month,
                              selectedMonth.year,
                              transactions,
                            );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('PDF disimpan: ${file.path}'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal ekspor: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(LucideIcons.download),
                    label: const Text('Unduh Laporan PDF'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> transactions,
  ) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Generate a set of unique year-month combinations from transactions
    final availableMonths = <DateTime>{
      DateTime(now.year, now.month), // Always include current month
    };

    for (var t in transactions) {
      availableMonths.add(DateTime(t.date.year, t.date.month));
    }

    // Convert to list and sort descending (newest first)
    final months = availableMonths.toList()..sort((a, b) => b.compareTo(a));

    // Formatting helper
    String formatMonth(DateTime date) {
      const monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${monthNames[date.month - 1]} ${date.year}';
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: months.map((date) {
          final isSelected =
              date.year == selectedMonth.year &&
              date.month == selectedMonth.month;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              selected: isSelected,
              label: Text(formatMonth(date)),
              onSelected: (bool selected) {
                if (selected) {
                  ref.read(selectedMonthProvider.notifier).state = date;
                }
              },
              backgroundColor: Colors.transparent,
              selectedColor: isDark
                  ? AppColors.darkInfoBg
                  : AppColors.primaryMuted,
              labelStyle: AppTextStyles.label.copyWith(
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primary)
                    : AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999), // Pill shape
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNetBalanceHero(
    BuildContext context,
    double netBalance,
    bool isDark,
  ) {
    return JapandiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: isDark ? AppColors.darkInfoBg : AppColors.infoBg,
      hasBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.wallet,
                size: 20,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Saldo Bersih Bulan Ini',
                style: AppTextStyles.label.copyWith(
                  color: isDark
                      ? AppColors.textInverseSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            CurrencyFormatter.format(netBalance),
            style: AppTextStyles.display.copyWith(
              color: isDark ? AppColors.textInverse : AppColors.textPrimary,
              fontFamily: 'JetBrainsMono',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color iconBg;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.iconBg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return JapandiCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.mono.copyWith(color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Map<String, double> categoryTotals;
  final double total;

  const _ChartCard({
    required this.title,
    required this.categoryTotals,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Japandi Earthy & Muted Colors
    final mutedPalette = [
      isDark ? const Color(0xFF6B87A8) : const Color(0xFF8BA5C4), // Muted Blue
      isDark ? const Color(0xFFA6856B) : const Color(0xFFC4A28B), // Muted Sand
      isDark ? const Color(0xFF8A9A83) : const Color(0xFFA5B49E), // Muted Sage
      isDark ? const Color(0xFFA87575) : const Color(0xFFC49393), // Muted Rose
      isDark
          ? const Color(0xFF8B7791)
          : const Color(0xFFA995AF), // Muted Lavender
      isDark ? const Color(0xFF9E927A) : const Color(0xFFBDB29C), // Muted Ochre
    ];

    return JapandiCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.xl),
          if (categoryTotals.isNotEmpty && total > 0)
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2, // Breathing room between sections
                  centerSpaceRadius: 60, // Donut style
                  sections: categoryTotals.entries.map((e) {
                    final color =
                        mutedPalette[e.key.hashCode.abs() %
                            mutedPalette.length];
                    return PieChartSectionData(
                      color: color,
                      value: e.value,
                      title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                      radius: 30, // Thinner ring
                      titleStyle: AppTextStyles.label.copyWith(
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 600),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            )
          else
            const SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Belum ada data',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final Color baseColor;

  const _CategoryBreakdownRow({
    required this.category,
    required this.amount,
    required this.total,
    required this.baseColor,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (amount / total) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor = isDark ? AppColors.darkSubtle : AppColors.surfaceSubtle;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                CurrencyFormatter.format(amount),
                style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            color: trackColor,
                          ),
                          FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: baseColor,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 48,
                child: Text(
                  '${(percent * 100).toStringAsFixed(1)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
