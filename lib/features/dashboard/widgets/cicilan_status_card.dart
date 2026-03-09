import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../shared/widgets/flat_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../../data/models/cicilan.dart';

class CicilanStatusCard extends StatelessWidget {
  final Cicilan cicilan;
  final int paidCount;

  const CicilanStatusCard({
    super.key,
    required this.cicilan,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    // Generate this month's due date
    final now = DateTime.now();
    DateTime dueDate = DateTime(now.year, now.month, cicilan.dueDay);

    // If we're past the due day and it's paid, the "next" due date is technically next month
    // but for the dashboard this month's scope is fine.

    final daysLeft = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    // Simplistic check for demo purposes: if we've made a payment this month
    // (In reality we'd check if there's a payment record for this specific month)
    // Here we'll just check if paidCount == totalTenor as fully paid, or pretend it's unpaid this month
    bool isPaidThisMonth = false; // We'll map this fully in the detail screen

    ChipStatus status;
    String statusLabel;

    if (paidCount >= cicilan.totalTenor) {
      status = ChipStatus.success;
      statusLabel = 'Lunas';
      isPaidThisMonth = true;
    } else if (daysLeft < 0 && !isPaidThisMonth) {
      status = ChipStatus.danger;
      statusLabel = 'Terlambat';
    } else if (daysLeft <= 3 && !isPaidThisMonth) {
      status = ChipStatus.warning;
      statusLabel = 'H-$daysLeft';
    } else {
      status = ChipStatus.neutral;
      statusLabel = daysLeft == 0
          ? 'Hari Ini'
          : (daysLeft > 0 ? 'H-$daysLeft' : 'Lewat');
    }

    return FlatCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkDangerBg
                        : AppColors.dangerBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.creditCard,
                      color: AppColors.danger,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cicilan.name,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            CurrencyFormatter.format(cicilan.monthlyAmount),
                            style: AppTextStyles.monoSmall,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$paidCount/${cicilan.totalTenor}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(label: statusLabel, status: status),
        ],
      ),
    );
  }
}
