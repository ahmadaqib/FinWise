import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/transaction_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_utils.dart';
import '../widgets/transaction_form.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.fileText,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada transaksi',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _openForm(context),
                    child: const Text('Catat Sekarang'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.type == 'income'
                        ? AppColors.successBg
                        : AppColors.dangerBg,
                    child: Icon(
                      t.type == 'income'
                          ? LucideIcons.arrowDownLeft
                          : LucideIcons.arrowUpRight,
                      color: t.type == 'income'
                          ? AppColors.success
                          : AppColors.danger,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    t.category,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${AppDateUtils.formatToIndonesianDate(t.date)}${t.note != null ? '\n${t.note}' : ''}',
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(t.amount),
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                      color: t.type == 'income'
                          ? AppColors.success
                          : AppColors.textPrimary,
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
      builder: (_) => const TransactionForm(),
    );
  }
}
