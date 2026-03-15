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
          'Kamu adalah analis FinWise. Patuhi sinyal algoritma internal, '
          'hindari saran generik, dan jawab maksimal 3 poin pendek.',
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
    'v2',
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

TUGAS:
1. Beri 3 insight tajam, 1 kalimat per poin.
2. Wajib merujuk metrik/trigger di atas (jangan generic).
3. Minimal 1 poin harus aksi 24 jam ke depan.
4. Setiap poin harus punya label risiko: [AMAN], [WASPADA], atau [KRITIS].
5. Bahasa kasual Indonesia, langsung ke inti.

FORMAT WAJIB:
1. ...
2. ...
3. ...''';
}

String _buildLocalAdaptiveInsight({
  required AIContextPackage context,
  required int healthScore,
  required String topCategorySummary,
  required int remainingDays,
  required List<AiInsight> algorithmInsights,
}) {
  final lines = <String>[];

  for (final insight in algorithmInsights.take(2)) {
    lines.add(
      '${_riskTagFromType(insight.type)} ${_compactText(insight.title)}: ${_compactText(insight.content)}',
    );
  }

  if (lines.length < 3) {
    if (context.remainingBudget <= 0 || context.adaptiveDailySafeLimit <= 0) {
      lines.add(
        '[KRITIS] Budget bebas sudah habis, hentikan belanja non-esensial sampai siklus berikutnya.',
      );
    } else {
      lines.add(
        '[${_overallRiskLabel(context: context, healthScore: healthScore)}] '
        'Batas aman harian sekarang ${CurrencyFormatter.format(context.adaptiveDailySafeLimit)} '
        'untuk menjaga sisa ${CurrencyFormatter.format(context.remainingBudget)} '
        'selama $remainingDays hari.',
      );
    }
  }

  if (lines.length < 3) {
    if (topCategorySummary.startsWith('Belum ada')) {
      lines.add(
        '[AMAN] Belum ada pola belanja dominan, pertahankan ritme supaya FLOW tetap stabil.',
      );
    } else {
      lines.add(
        '[WASPADA] Prioritaskan kontrol di kategori terbesar: $topCategorySummary.',
      );
    }
  }

  if (lines.length < 3) {
    lines.add(
      '[WASPADA] Aksi 24 jam: jaga total belanja hari ini di bawah ${CurrencyFormatter.format(context.adaptiveDailySafeLimit)}.',
    );
  }

  final normalizedLines = lines.take(3).toList();
  return List.generate(
    normalizedLines.length,
    (index) => '${index + 1}. ${normalizedLines[index]}',
  ).join('\n');
}

String _riskTagFromType(String type) {
  switch (type) {
    case 'warning':
      return '[KRITIS]';
    case 'achievement':
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
