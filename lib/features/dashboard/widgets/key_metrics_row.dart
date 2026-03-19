import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/flat_card.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/hideable_amount_text.dart';

class KeyMetricsRow extends StatelessWidget {
  final double remainingBudget;
  final double dailyLimitRemaining;
  final double dailyLimitBase;
  final String dailyLimitResetCountdown;

  const KeyMetricsRow({
    super.key,
    required this.remainingBudget,
    required this.dailyLimitRemaining,
    required this.dailyLimitBase,
    required this.dailyLimitResetCountdown,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FlatCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tersisa Bulan Ini',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: remainingBudget,
                  formatter: CurrencyFormatter.format,
                  style: AppTextStyles.monoLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: FlatCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sisa Limit Hari Ini',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: dailyLimitRemaining,
                  formatter: CurrencyFormatter.format,
                  style: AppTextStyles.monoLarge.copyWith(
                    color: dailyLimitRemaining < 0
                        ? AppColors.danger
                        : AppColors.success,
                  ),
                ),
                const SizedBox(height: 6),
                HideableAmountText(
                  text: dailyLimitRemaining < 0
                      ? 'Melebihi limit ${CurrencyFormatter.format(dailyLimitRemaining.abs())}'
                      : 'Dari limit ${CurrencyFormatter.format(dailyLimitBase)}',
                  style: AppTextStyles.caption.copyWith(
                    color: dailyLimitRemaining < 0
                        ? AppColors.danger
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dailyLimitResetCountdown,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
