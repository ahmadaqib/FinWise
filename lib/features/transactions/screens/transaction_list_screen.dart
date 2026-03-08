import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/transaction_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/japandi_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../data/models/transaction.dart';
import '../widgets/transaction_form.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: transactions.isEmpty
          ? EmptyState(
              icon: LucideIcons.receipt,
              title: 'Belum ada transaksi',
              description:
                  'Catat pemasukan dan pengeluaranmu untuk mulai melacak keuangan.',
              actionLabel: 'Catat Sekarang',
              onAction: () => _openForm(context),
            )
          : Stack(
              children: [
                _buildTransactionList(context, transactions, isDark),
                _buildBottomStickyCTA(context, isDark),
              ],
            ),
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<Transaction> transactions,
    bool isDark,
  ) {
    // Group transactions by date string
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      final dateStr = AppDateUtils.formatToIndonesianDate(t.date);
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      grouped[dateStr]!.add(t);
    }

    final dates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: 100, // Space for sticky CTA
      ),
      itemCount: dates.length,
      itemBuilder: (context, index) {
        final dateStr = dates[index];
        final dailyTransactions = grouped[dateStr]!;

        // Determine if it's today or yesterday for standard labels
        final today = AppDateUtils.formatToIndonesianDate(DateTime.now());
        final yesterday = AppDateUtils.formatToIndonesianDate(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        String displayDate = dateStr;
        if (dateStr == today) displayDate = 'Hari Ini';
        if (dateStr == yesterday) displayDate = 'Kemarin';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Text(
                displayDate,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ...dailyTransactions.map(
              (t) => _buildTransactionCard(context, t, isDark),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction t,
    bool isDark,
  ) {
    final isIncome = t.type == 'income';

    // Softer earthy colors for icon backgrounds
    final iconBgColor = isIncome
        ? (isDark ? AppColors.darkSuccessBg : const Color(0xFFE8F2EC))
        : (isDark ? AppColors.darkDangerBg : const Color(0xFFF9EAE8));

    final iconColor = isIncome
        ? (isDark ? const Color(0xFF86CCA0) : AppColors.success)
        : (isDark ? const Color(0xFFF09898) : AppColors.danger);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: JapandiCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: () {
          // If has image, show image maybe? For now just show image if it exists
          if (t.imageRef != null) {
            _showImage(context, t.imageRef!);
          }
        },
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(t.category),
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        t.category,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (t.imageRef != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          LucideIcons.paperclip,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ],
                  ),
                  if (t.note != null && t.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      t.note!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(t.amount).replaceAll('Rp', '')}',
              style: AppTextStyles.mono.copyWith(
                color: isIncome ? iconColor : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return LucideIcons.coffee;
      case 'transportasi':
        return LucideIcons.car;
      case 'belanja':
        return LucideIcons.shoppingBag;
      case 'hiburan':
        return LucideIcons.tv;
      case 'tagihan':
        return LucideIcons.fileText;
      case 'kesehatan':
        return LucideIcons.activity;
      case 'pendidikan':
        return LucideIcons.bookOpen;
      case 'gaji':
      case 'pendapatan utama':
        return LucideIcons.wallet;
      case 'investasi':
        return LucideIcons.trendingUp;
      case 'bonus':
      case 'freelance':
      case 'lainnya':
      default:
        return LucideIcons.moreHorizontal;
    }
  }

  Widget _buildBottomStickyCTA(BuildContext context, bool isDark) {
    return Positioned(
      bottom: AppSpacing.xl,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.5)
                  : AppColors.surface.withOpacity(0.9),
              blurRadius: 24,
              spreadRadius: 8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _openForm(context),
          icon: const Icon(LucideIcons.plusCircle, color: Colors.white),
          label: const Text('Catat Transaksi Baru'),
          style: ElevatedButton.styleFrom(
            shadowColor:
                Colors.transparent, // Disable standard shadow for custom glow
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransactionForm(),
    );
  }

  void _showImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(File(imagePath), fit: BoxFit.contain),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
