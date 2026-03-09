import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/flat_card.dart';
import '../../../../shared/widgets/status_chip.dart';

class InsightCard extends StatelessWidget {
  final String insight;

  const InsightCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FlatCard(
      backgroundColor: isDark
          ? AppColors.darkWarningBg
          : const Color(0xFFFCF9EC), // Very soft warm tint
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Insight Hari Ini',
                    style: AppTextStyles.label.copyWith(
                      color: isDark
                          ? AppColors.textInverse
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const StatusChip(label: 'AI', status: ChipStatus.info),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.replaceAll('**', '').replaceAll('*', ''),
            style: AppTextStyles.body.copyWith(
              color: isDark
                  ? AppColors.textInverseSecondary
                  : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
