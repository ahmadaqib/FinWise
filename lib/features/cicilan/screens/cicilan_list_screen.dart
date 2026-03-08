import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/cicilan_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/japandi_card.dart';
import '../widgets/cicilan_form.dart';
import 'cicilan_detail_screen.dart';

class CicilanListScreen extends ConsumerWidget {
  const CicilanListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCicilans = ref.watch(cicilanListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Cicilan')),
      body: activeCicilans.isEmpty
          ? EmptyState(
              icon: LucideIcons.calendarClock,
              title: 'Belum Ada Cicilan',
              description:
                  'Catat cicilan KPR, kendaraan, atau belanjaanmu di sini.',
              actionLabel: 'Tambah Cicilan',
              onAction: () => _openForm(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: activeCicilans.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final cicilan = activeCicilans[index];
                final paidCount = ref.watch(
                  cicilanPaidCountProvider(cicilan.id),
                );
                final progress = cicilan.totalTenor > 0
                    ? paidCount / cicilan.totalTenor
                    : 0.0;

                return JapandiCard(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CicilanDetailScreen(cicilanId: cicilan.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                cicilan.name,
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primaryMuted.withValues(
                                        alpha: 0.2,
                                      )
                                    : AppColors.primaryLight.withValues(
                                        alpha: 0.2,
                                      ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$paidCount / ${cicilan.totalTenor}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Jatuh tempo tgl ${cicilan.dueDay}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(cicilan.monthlyAmount),
                              style: AppTextStyles.mono.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              progress >= 1.0
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }

  void _openForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CicilanForm(),
    );
  }
}
