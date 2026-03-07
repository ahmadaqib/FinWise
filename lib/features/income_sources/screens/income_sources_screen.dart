import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/income_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../widgets/income_source_form.dart';

class IncomeSourcesScreen extends ConsumerWidget {
  const IncomeSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomes = ref.watch(incomeProvider);
    final activeIncomes = incomes.where((i) => i.isActive).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sumber Pendapatan')),
      body: activeIncomes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.wallet,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada sumber pendapatan',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _openForm(context),
                    child: const Text('Tambah Sekarang'),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: activeIncomes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final income = activeIncomes[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      income.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${income.type} • Tgl ${income.receivedOnDay}',
                      ),
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(income.amount),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onTap: () => _openForm(context, incomeId: income.id),
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

  void _openForm(BuildContext context, {String? incomeId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IncomeSourceForm(incomeId: incomeId),
    );
  }
}
