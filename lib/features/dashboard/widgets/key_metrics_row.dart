import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/japandi_card.dart';
import '../../../../shared/widgets/animated_counter.dart';

class KeyMetricsRow extends StatelessWidget {
  final double remainingBudget;
  final double dailyLimit;

  const KeyMetricsRow({
    super.key,
    required this.remainingBudget,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: JapandiCard(
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
          child: JapandiCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batas Aman Harian',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedCounter(
                  value: dailyLimit,
                  formatter: CurrencyFormatter.format,
                  style: AppTextStyles.monoLarge.copyWith(
                    color: AppColors.success,
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
