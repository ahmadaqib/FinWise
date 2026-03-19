import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/flat_card.dart';
import '../../../../shared/widgets/hideable_amount_text.dart';

class BudgetMeterCard extends ConsumerWidget {
  final double expense;
  final double remaining;
  final double totalBudget;

  const BudgetMeterCard({
    super.key,
    required this.expense,
    required this.remaining,
    required this.totalBudget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final percentage = totalBudget > 0 ? (expense / totalBudget * 100) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emptyColor = isDark ? AppColors.darkSubtle : AppColors.surfaceSubtle;
    final primaryFillColor = isDark
        ? AppColors.primaryLight
        : AppColors.primary;

    return FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Penggunaan Budget', style: AppTextStyles.heading2),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: AppTextStyles.mono.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2, // adding bit of space for zen feel
                    centerSpaceRadius: 75, // thinner rings
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: primaryFillColor,
                        value: expense > 0 ? expense : 0.1,
                        title: '',
                        radius: 12, // thinner
                      ),
                      PieChartSectionData(
                        color: emptyColor,
                        value: remaining > 0 ? remaining : 0.1,
                        title: '',
                        radius: 12,
                      ),
                    ],
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.easeOutCubic,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total Bebas',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      HideableAmountText(
                        text: CurrencyFormatter.format(totalBudget),
                        style: AppTextStyles.monoLarge.copyWith(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegend('Terpakai', expense, primaryFillColor),
              _buildLegend('Sisa', remaining, emptyColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, double amount, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            HideableAmountText(
              text: CurrencyFormatter.format(amount),
              style: AppTextStyles.monoSmall,
            ),
          ],
        ),
      ],
    );
  }
}
