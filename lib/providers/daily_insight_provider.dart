import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/currency_formatter.dart';
import '../core/utils/date_utils.dart';
import '../data/models/ai_context_package.dart';
import '../data/models/ai_insight.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../services/gemini_service.dart';
import 'budget_provider.dart';
import 'rpd_counter_provider.dart';
import 'transaction_provider.dart';

const int _dailyInsightTtlMinutes = 24 * 60;

/// Provider for daily insight text.
/// Dynamic: refreshes when key financial signals change (not just date).
/// Efficient: cache key is based on coarse financial fingerprint.
final dailyInsightProvider = FutureProvider<String?>((ref) async {
  final cacheRepo = AiCacheRepository();
  final now = DateTime.now();

  final context = ref.watch(aiContextPackageProvider);
  final healthScore = ref.watch(healthScoreProvider);
  final cycle = ref.watch(currentCycleProvider);
  final transactions = ref.watch(transactionProvider);
  final algorithmInsights = ref.watch(aiInsightsProvider);

  final start = cycle['start']!;
  final end = cycle['end']!;

  final cycleExpenses = transactions.where(
    (t) =>
        t.type == 'expense' &&
        t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
        t.date.isBefore(end.add(const Duration(seconds: 1))),
  );

  final topCategories = <String, double>{};
  for (final tx in cycleExpenses) {
    topCategories[tx.category] = (topCategories[tx.category] ?? 0) + tx.amount;
  }

  final sortedCategories = topCategories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final topCategorySummary = sortedCategories.isEmpty
      ? 'Belum ada pengeluaran tercatat di siklus ini.'
      : sortedCategories
            .take(3)
            .map((e) => '${e.key}: ${CurrencyFormatter.format(e.value)}')
            .join(', ');

  final topCategoryNames = sortedCategories.take(3).map((e) => e.key).join('|');
  final remainingDays = AppDateUtils.getRemainingDaysInCycle(now, end);

  final fingerprint = _buildDailyFingerprint(
    now: now,
    context: context,
    healthScore: healthScore,
    remainingDays: remainingDays,
    topCategoryNames: topCategoryNames,
    algorithmInsights: algorithmInsights,
  );
  final digest = sha1
      .convert(utf8.encode(fingerprint))
      .toString()
      .substring(0, 12);
  final insightKey =
      'daily_insight_${now.year}_${now.month}_${now.day}_$digest';

  final cached = cacheRepo.getCachedResponse(insightKey);
  if (cached != null) return cached;

  final fallback = _buildLocalAdaptiveInsight(
    context: context,
    healthScore: healthScore,
    topCategorySummary: topCategorySummary,
    remainingDays: remainingDays,
    algorithmInsights: algorithmInsights,
  );

  if (!RpdCounter.canMakeRequest) {
    return fallback;
  }

  final prompt = _buildPrompt(
    context: context,
    healthScore: healthScore,
    cycleStart: start,
    cycleEnd: end,
    remainingDays: remainingDays,
    topCategorySummary: topCategorySummary,
    algorithmInsights: algorithmInsights,
  );

  try {
    final gemini = ref.read(geminiServiceProvider);
    final response = await gemini.askAdvisor(
      prompt,
      systemContext:
          'Kamu adalah advisor keuangan personal FinWise yang komunikatif dan '
          'jelas. Pakai bahasa Indonesia natural, jelaskan sebab-akibat '
          'berbasis data, dan berikan insight seimbang (risiko + peluang + aksi).',
    );

    if (_isGeminiServiceError(response)) {
      return fallback;
    }

    final cleaned = response.trim();
    if (cleaned.isEmpty) {
      return fallback;
    }

    await RpdCounter.increment();
    await cacheRepo.cacheResponse(
      insightKey,
      cleaned,
      ttlMinutes: _dailyInsightTtlMinutes,
    );

    return cleaned;
  } catch (_) {
    return fallback;
  }
});

String _buildDailyFingerprint({
  required DateTime now,
  required AIContextPackage context,
  required int healthScore,
  required int remainingDays,
  required String topCategoryNames,
  required List<AiInsight> algorithmInsights,
}) {
  final types = algorithmInsights.map((i) => i.type).toSet().toList()..sort();
  final riskTitles = algorithmInsights
      .take(2)
      .map((i) => _compactText(i.title))
      .join('|');

  return [
    'v3',
    '${now.year}-${now.month}-${now.day}',
    'remaining:${_bucket(context.remainingBudget, 50000).toInt()}',
    'limit:${_bucket(context.adaptiveDailySafeLimit, 10000).toInt()}',
    'flow:${context.flowScore.toStringAsFixed(0)}',
    'velocity:${context.spendingVelocity.toStringAsFixed(1)}',
    'fws:${context.fwsBand}',
    'health:$healthScore',
    'days:$remainingDays',
    'freeZone:${_bucket(context.zoneDistribution['free'] ?? 0, 25000).toInt()}',
    'top:$topCategoryNames',
    'types:${types.join(',')}',
    'risk:$riskTitles',
  ].join(';');
}

String _buildPrompt({
  required AIContextPackage context,
  required int healthScore,
  required DateTime cycleStart,
  required DateTime cycleEnd,
  required int remainingDays,
  required String topCategorySummary,
  required List<AiInsight> algorithmInsights,
}) {
  final triggerSummary = algorithmInsights.isEmpty
      ? '- Tidak ada trigger kritis dari rule-engine.'
      : algorithmInsights
            .take(3)
            .map(
              (insight) =>
                  '- ${_compactText(insight.title)}: ${_compactText(insight.content)}',
            )
            .join('\n');

  final positiveSignals = <String>[];
  if (context.flowScore >= 70) {
    positiveSignals.add(
      'Flow score ${context.flowScore.toStringAsFixed(1)} menunjukkan kontrol pengeluaran cukup sehat.',
    );
  }
  if (context.spendingVelocity <= 1.0) {
    positiveSignals.add(
      'Spending velocity ${context.spendingVelocity.toStringAsFixed(2)}x masih dalam ritme aman.',
    );
  }
  if (context.currentFWS >= 450) {
    positiveSignals.add(
      'FWS ${context.currentFWS.toStringAsFixed(0)} berada di band ${context.fwsBand} dan bisa dijaga untuk naik bertahap.',
    );
  }
  final positiveSummary = positiveSignals.isEmpty
      ? '- Belum ada sinyal positif dominan; fokuskan perbaikan ritme belanja.'
      : positiveSignals.take(2).map((signal) => '- $signal').join('\n');

  return '''KONTEKS SIKLUS KEUANGAN (${cycleStart.day}/${cycleStart.month} - ${cycleEnd.day}/${cycleEnd.month})
- Sisa budget bebas: ${CurrencyFormatter.format(context.remainingBudget)}
- Adaptive Daily Limit (FlowEngine): ${CurrencyFormatter.format(context.adaptiveDailySafeLimit)}
- Sisa hari siklus: $remainingDays hari
- Flow score: ${context.flowScore.toStringAsFixed(1)} / 100
- Spending velocity: ${context.spendingVelocity.toStringAsFixed(2)}x (ideal 1.00x)
- FWS: ${context.currentFWS.toStringAsFixed(0)} (${context.fwsBand})
- Health score: $healthScore/100
- Zona (Shield/Flow/Grow/Free): ${CurrencyFormatter.format(context.zoneDistribution['shield'] ?? 0)} / ${CurrencyFormatter.format(context.zoneDistribution['flow'] ?? 0)} / ${CurrencyFormatter.format(context.zoneDistribution['grow'] ?? 0)} / ${CurrencyFormatter.format(context.zoneDistribution['free'] ?? 0)}
- Top kategori: $topCategorySummary

TRIGGER RULE-ENGINE:
$triggerSummary

SINYAL POSITIF SAAT INI:
$positiveSummary

TUGAS:
1. Beri tepat 3 poin insight, tiap poin 2 kalimat (diagnosis + aksi konkret).
2. Wajib merujuk metrik/trigger di atas dan minimal 1 angka per poin.
3. Komposisi poin: kondisi utama, peluang/perbaikan, dan aksi 24 jam.
4. Setiap poin harus punya label risiko: [AMAN], [WASPADA], atau [KRITIS].
5. Bahasa kasual Indonesia yang natural, hindari gaya robotik.
6. Jangan hanya mengulang kata "warning"; jelaskan kenapa dan dampaknya.

FORMAT WAJIB:
1. [LABEL] ...
2. [LABEL] ...
3. [LABEL] ...''';
}

String _buildLocalAdaptiveInsight({
  required AIContextPackage context,
  required int healthScore,
  required String topCategorySummary,
  required int remainingDays,
  required List<AiInsight> algorithmInsights,
}) {
  final overallLabel = _overallRiskLabel(
    context: context,
    healthScore: healthScore,
  );
  final safeLimit = context.adaptiveDailySafeLimit > 0
      ? context.adaptiveDailySafeLimit
      : 0.0;
  final budgetLeft = CurrencyFormatter.format(context.remainingBudget);
  final dailyLimit = CurrencyFormatter.format(safeLimit);

  final primaryTrigger = algorithmInsights.isNotEmpty
      ? algorithmInsights.first
      : null;
  final firstLine = primaryTrigger != null
      ? '${_riskTagFromType(primaryTrigger.type)} ${_compactText(primaryTrigger.title)}. '
            '${_compactText(primaryTrigger.content)}'
      : '[$overallLabel] Sisa budget bebas kamu sekarang $budgetLeft '
            'dengan spending velocity ${context.spendingVelocity.toStringAsFixed(2)}x. '
            'Ini jadi sinyal utama untuk atur ritme belanja sisa $remainingDays hari.';

  final secondLine = topCategorySummary.startsWith('Belum ada')
      ? '[AMAN] Belum ada kategori pengeluaran dominan, ini peluang bagus untuk menjaga FLOW tetap stabil. '
            'Pertahankan pola catatan harian supaya batas aman tetap terjaga.'
      : '[WASPADA] Pengeluaran terbesar saat ini ada di $topCategorySummary. '
            'Kontrol kategori ini dulu supaya velocity ${context.spendingVelocity.toStringAsFixed(2)}x bisa turun mendekati 1.00x.';

  final thirdLine = safeLimit <= 0
      ? '[KRITIS] Aksi 24 jam: hentikan dulu belanja non-prioritas dan catat hanya kebutuhan wajib. '
            'Fokus menahan arus keluar sampai siklus berikutnya.'
      : '[${overallLabel == 'AMAN' ? 'WASPADA' : overallLabel}] Aksi 24 jam: batasi total belanja hari ini maksimal $dailyLimit. '
            'Langkah ini membantu menjaga sisa $budgetLeft tetap cukup untuk $remainingDays hari.';

  return '1. $firstLine\n2. $secondLine\n3. $thirdLine';
}

String _riskTagFromType(String type) {
  switch (type) {
    case 'warning':
      return '[WASPADA]';
    case 'achievement':
    case 'opportunity':
      return '[AMAN]';
    default:
      return '[WASPADA]';
  }
}

String _overallRiskLabel({
  required AIContextPackage context,
  required int healthScore,
}) {
  if (context.remainingBudget <= 0 ||
      context.adaptiveDailySafeLimit <= 0 ||
      healthScore <= 25 ||
      context.currentFWS < 250) {
    return 'KRITIS';
  }

  if (healthScore <= 50 ||
      context.spendingVelocity > 1.2 ||
      context.flowScore < 70 ||
      context.currentFWS < 450) {
    return 'WASPADA';
  }

  return 'AMAN';
}

double _bucket(double value, double size) {
  if (size <= 0) return value;
  return (value / size).round() * size;
}

String _compactText(String text) {
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}

bool _isGeminiServiceError(String response) {
  final lower = response.toLowerCase();
  return lower.contains('belum mengatur gemini api key') ||
      lower.contains('semua kombinasi api key') ||
      lower.contains('sedang limit/error');
}
