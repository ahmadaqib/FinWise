import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../../../providers/cicilan_provider.dart';
import '../../../data/models/cicilan_payment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/flat_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../widgets/cicilan_form.dart';

class CicilanDetailScreen extends ConsumerWidget {
  final String cicilanId;

  const CicilanDetailScreen({super.key, required this.cicilanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cicilan = ref
        .watch(cicilanListProvider)
        .firstWhere(
          (c) => c.id == cicilanId,
          orElse: () => throw Exception('Cicilan not found'),
        );
    final payments = ref.watch(cicilanPaymentsProvider(cicilanId));
    final paidCount = ref.watch(cicilanPaidCountProvider(cicilanId));

    final isLunas = paidCount >= cicilan.totalTenor;
    final progress = cicilan.totalTenor > 0
        ? paidCount / cicilan.totalTenor
        : 0.0;

    final now = DateTime.now();
    final dueDate = DateTime(now.year, now.month, cicilan.dueDay);
    final isPaidThisMonth = payments.any(
      (p) => p.paidDate.year == now.year && p.paidDate.month == now.month,
    );

    final daysLeft = dueDate
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cicilan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.edit3),
            onPressed: () => _openForm(context, cicilan),
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppColors.danger),
            onPressed: () => _confirmDelete(context, ref, cicilan.name),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ==== Header Card ====
                  FlatCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cicilan.name,
                                    style: AppTextStyles.heading2,
                                  ),
                                  if (cicilan.note != null &&
                                      cicilan.note!.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      cicilan.note!,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isLunas)
                              const StatusChip(
                                label: 'Lunas',
                                status: ChipStatus.success,
                              )
                            else if (daysLeft < 0 && !isPaidThisMonth)
                              const StatusChip(
                                label: 'Terlambat',
                                status: ChipStatus.danger,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Progress
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '$paidCount dari ${cicilan.totalTenor} bulan',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLunas ? AppColors.success : AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Grid Details
                        Row(
                          children: [
                            Expanded(
                              child: _buildDetailItem(
                                'Cicilan / bln',
                                CurrencyFormatter.format(cicilan.monthlyAmount),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _buildDetailItem(
                                'Total Pokok',
                                CurrencyFormatter.format(cicilan.totalAmount),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ==== Action / Payment Status ====
                  if (!isLunas) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pembayaran Bulan Ini',
                          style: AppTextStyles.heading2.copyWith(fontSize: 18),
                        ),
                        if (!isPaidThisMonth)
                          Text(
                            'Jatuh tempo: tgl ${cicilan.dueDay}',
                            style: AppTextStyles.caption.copyWith(
                              color: daysLeft < 0
                                  ? AppColors.danger
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (isPaidThisMonth)
                      FlatCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        backgroundColor: AppColors.successBg,
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.checkCircle2,
                              color: AppColors.success,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Sudah dibayar bulan ini',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _markAsPaid(context, ref, cicilan),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(LucideIcons.checkSquare),
                        label: Text('Bayar Cicilan ke-${paidCount + 1}'),
                      ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  Text(
                    'Riwayat Pembayaran',
                    style: AppTextStyles.heading2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          if (payments.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: EmptyState(
                  icon: LucideIcons.history,
                  title: 'Belum Ada Riwayat',
                  description:
                      'Riwayat pembayaran cicilan akan muncul di sini.',
                  actionLabel: 'Tutup',
                  onAction: () => Navigator.pop(context),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final payment = payments[index];
                return Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    bottom: AppSpacing.sm,
                  ),
                  child: FlatCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.primaryMuted.withValues(alpha: 0.2)
                              : AppColors.primaryLight.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${payment.paymentNumber}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        CurrencyFormatter.format(payment.amount),
                        style: AppTextStyles.mono.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(payment.paidDate),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () =>
                            _confirmDeletePayment(context, ref, payment),
                      ),
                    ),
                  ),
                );
              }, childCount: payments.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.monoSmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  void _openForm(BuildContext context, cicilan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CicilanForm(existingCicilan: cicilan),
    );
  }

  Future<void> _markAsPaid(BuildContext context, WidgetRef ref, cicilan) async {
    final paidCount = ref.read(cicilanPaidCountProvider(cicilan.id));

    final payment = CicilanPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      cicilanId: cicilan.id,
      paymentNumber: paidCount + 1,
      amount: cicilan.monthlyAmount,
      paidDate: DateTime.now(),
    );

    await ref
        .read(cicilanPaymentsProvider(cicilan.id).notifier)
        .addPayment(payment);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pembayaran ke-${paidCount + 1} berhasil dicatat'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Cicilan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus cicilan "$name"? Pilih "Hapus" tidak akan mengembalikan dana yang sudah terbayar pada history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref.read(cicilanListProvider.notifier).deleteCicilan(cicilanId);
      Navigator.pop(context); // Go back to list
    }
  }

  Future<void> _confirmDeletePayment(
    BuildContext context,
    WidgetRef ref,
    CicilanPayment payment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pembayaran?'),
        content: Text('Hapus riwayat pembayaran ke-${payment.paymentNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref
          .read(cicilanPaymentsProvider(cicilanId).notifier)
          .deletePayment(payment.id);
    }
  }
}
