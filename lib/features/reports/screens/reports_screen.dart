import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/transaction_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Group by category
    final Map<String, double> categoryTotals = {};
    for (var t in expenses) {
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
    }

    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () {
              // PDF export logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Pengeluaran',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(totalExpense),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono',
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (categoryTotals.isNotEmpty)
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                            sections: categoryTotals.entries.map((e) {
                              final colorList = [
                                AppColors.primary,
                                AppColors.success,
                                AppColors.warning,
                                AppColors.danger,
                                AppColors.info,
                              ];
                              final color =
                                  colorList[e.key.hashCode.abs() %
                                      colorList.length];
                              return PieChartSectionData(
                                color: color,
                                value: e.value,
                                title:
                                    '${(e.value / totalExpense * 100).toStringAsFixed(0)}%',
                                radius: 40,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    else
                      const Center(
                        child: Text(
                          'Belum ada data pengeluaran',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rincian Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...categoryTotals.entries.map((e) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    CurrencyFormatter.format(e.value),
                    style: const TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
