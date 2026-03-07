import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/transaction_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../services/pdf_export_service.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);
    final now = DateTime.now();

    final monthlyTransactions = transactions
        .where((t) => t.date.year == now.year && t.date.month == now.month)
        .toList();

    final expenses = monthlyTransactions
        .where((t) => t.type == 'expense')
        .toList();
    final incomes = monthlyTransactions
        .where((t) => t.type == 'income')
        .toList();

    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = incomes.fold(0.0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    // Group expenses by category
    final Map<String, double> expenseCats = {};
    for (var t in expenses) {
      expenseCats[t.category] = (expenseCats[t.category] ?? 0) + t.amount;
    }

    // Group incomes by category
    final Map<String, double> incomeCats = {};
    for (var t in incomes) {
      final cat = t.category.isEmpty ? 'Pemasukan' : t.category;
      incomeCats[cat] = (incomeCats[cat] ?? 0) + t.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Bulanan'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.download),
            onPressed: () async {
              try {
                final file = await PdfExportService.generateMonthlyReport(
                  now.month,
                  now.year,
                  transactions,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF disimpan: ${file.path}')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Gagal ekspor: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary cards row
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Pemasukan',
                    amount: totalIncome,
                    color: AppColors.success,
                    icon: LucideIcons.arrowDownLeft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Pengeluaran',
                    amount: totalExpense,
                    color: AppColors.danger,
                    icon: LucideIcons.arrowUpRight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Net balance card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo Bersih',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(netBalance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'JetBrainsMono',
                        color: netBalance >= 0
                            ? AppColors.success
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expense chart
            const SizedBox(height: 24),
            _ChartCard(
              title: 'Pengeluaran per Kategori',
              categoryTotals: expenseCats,
              total: totalExpense,
            ),

            // Income chart
            const SizedBox(height: 24),
            _ChartCard(
              title: 'Pemasukan per Kategori',
              categoryTotals: incomeCats,
              total: totalIncome,
            ),

            // Expense breakdown
            if (expenseCats.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Rincian Pengeluaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...expenseCats.entries.map(
                (e) => _CategoryTile(
                  category: e.key,
                  amount: e.value,
                  total: totalExpense,
                  color: AppColors.danger,
                ),
              ),
            ],

            // Income breakdown
            if (incomeCats.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Rincian Pemasukan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...incomeCats.entries.map(
                (e) => _CategoryTile(
                  category: e.key,
                  amount: e.value,
                  total: totalIncome,
                  color: AppColors.success,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'JetBrainsMono',
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Map<String, double> categoryTotals;
  final double total;

  const _ChartCard({
    required this.title,
    required this.categoryTotals,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (categoryTotals.isNotEmpty && total > 0)
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
                          colorList[e.key.hashCode.abs() % colorList.length];
                      return PieChartSectionData(
                        color: color,
                        value: e.value,
                        title: '${(e.value / total * 100).toStringAsFixed(0)}%',
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
                  'Belum ada data',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final Color color;

  const _CategoryTile({
    required this.category,
    required this.amount,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (amount / total * 100) : 0.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(category),
        subtitle: LinearProgressIndicator(
          value: total > 0 ? amount / total : 0,
          backgroundColor: AppColors.primaryMuted,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              CurrencyFormatter.format(amount),
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
