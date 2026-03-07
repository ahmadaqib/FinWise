import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../core/utils/currency_formatter.dart';
import '../services/gemini_service.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';
import 'rpd_counter_provider.dart';

/// Provider for daily insight text. Generates once per day, cached locally.
final dailyInsightProvider = FutureProvider<String?>((ref) async {
  final cacheRepo = AiCacheRepository();
  final now = DateTime.now();
  final insightKey = 'daily_insight_${now.year}_${now.month}_${now.day}';

  // Check if already generated today
  final cached = cacheRepo.getCachedResponse(insightKey);
  if (cached != null) return cached;

  // Check RPD availability
  if (!RpdCounter.canMakeRequest) return null;

  // Build a compact context for the insight
  final grossIncome = ref.read(totalFixedIncomeProvider);
  final remaining = ref.read(remainingBudgetProvider);
  final expense = ref.read(totalExpenseThisMonthProvider);
  final healthScore = ref.read(healthScoreProvider);
  final dailyLimit = ref.read(dailySafeLimitProvider);

  final transactions = ref.read(transactionProvider);
  final monthlyExpenses = transactions.where(
    (t) =>
        t.type == 'expense' &&
        t.date.year == now.year &&
        t.date.month == now.month,
  );
  final topCategories = <String, double>{};
  for (final t in monthlyExpenses) {
    topCategories[t.category] = (topCategories[t.category] ?? 0) + t.amount;
  }
  final catSummary = topCategories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top3 = catSummary
      .take(3)
      .map((e) => '${e.key}: ${CurrencyFormatter.format(e.value)}')
      .join(', ');

  final prompt =
      '''Berikan 3 insight keuangan singkat (masing-masing max 1 kalimat) berdasarkan data ini:
- Pemasukan: ${CurrencyFormatter.format(grossIncome)}
- Pengeluaran bulan ini: ${CurrencyFormatter.format(expense)} (top: $top3)
- Tersisa: ${CurrencyFormatter.format(remaining)}
- Limit harian: ${CurrencyFormatter.format(dailyLimit)}
- Skor: $healthScore/100
Format: nomor 1-3, bahasa kasual Indonesia, langsung ke poin.''';

  try {
    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.askAdvisor(
      prompt,
      systemContext:
          'Kamu adalah analis keuangan ringkas. Jawab dalam 3 poin pendek saja.',
    );

    await RpdCounter.increment();
    await cacheRepo.cacheResponse(insightKey, response);

    return response;
  } catch (_) {
    return null;
  }
});
