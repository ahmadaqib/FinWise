import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../data/repositories/user_profile_repository.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../core/utils/currency_formatter.dart';
import 'budget_provider.dart';
import 'income_provider.dart';
import 'transaction_provider.dart';
import 'rpd_counter_provider.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final geminiService = ref.read(geminiServiceProvider);
  return ChatNotifier(geminiService, ref);
});

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;
  final Ref _ref;
  bool isLoading = false;

  ChatNotifier(this._geminiService, this._ref)
    : super([
        ChatMessage(
          text:
              "Halo! Saya FinWise AI Advisor Anda. Ada yang bisa saya bantu terkait keuangan Anda hari ini?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);

  // ── PERSONA (statis, di-cache oleh Gemini systemInstruction) ──
  String _buildPersona() {
    return '''Anda adalah FinWise AI — penasihat keuangan pribadi dengan pola pikir Warren Buffett dan kejelian analis keuangan berpengalaman 80 tahun.
Kepribadian: Tegas, to-the-point, berbasis data, selalu prioritaskan keamanan modal sebelum pertumbuhan.

ATURAN KETAT:
1. DILARANG mengulang data keuangan user kecuali ditanya spesifik.
2. DILARANG basa-basi. LANGSUNG ke inti jawaban.
3. Jawaban MAKSIMAL 3 poin ringkas.
4. Untuk saran investasi WAJIB sertakan:
   a. Nominal Rupiah ideal (dari "Uang Tersisa" dikurangi dana darurat 20%).
   b. 1-2 instrumen spesifik dengan alasan berdasarkan tren makroekonomi saat ini.
   c. Persentase alokasi (misal: 60% reksadana, 40% SBN).
5. Jika skor < 50 atau cicilan > 40% income: TOLAK saran investasi, suruh perbaiki fundamental.
6. Gunakan bahasa kasual Indonesia.''';
  }

  // ── FINANCIAL SNAPSHOT (semi-statis, ringkas) ──
  String _buildFinancialSnapshot() {
    final grossIncome = _ref.read(totalFixedIncomeProvider);
    final cicilan = _ref.read(currentCicilanProvider);
    final freeBudget = _ref.read(freeBudgetProvider);
    final remainingBudget = _ref.read(remainingBudgetProvider);
    final dailyLimit = _ref.read(dailySafeLimitProvider);
    final totalExpense = _ref.read(totalExpenseThisMonthProvider);
    final healthScore = _ref.read(healthScoreProvider);
    final profile = UserProfileRepository().getProfile();

    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;

    final dayNames = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    final monthNames = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    final incomes = _ref.read(incomeProvider);
    final paydayInfo = incomes
        .where(
          (s) =>
              s.isActive && (s.type == 'fixed_monthly' || s.type == 'passive'),
        )
        .map((s) => "${s.name}(tgl ${s.receivedOnDay})")
        .join(', ');

    // Hitung total pemasukan dari transaksi bulan ini
    final transactions = _ref.read(transactionProvider);
    final monthlyIncome = transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    // Category summaries
    final expenseMap = <String, double>{};
    final incomeMap = <String, double>{};
    for (final t in transactions.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    )) {
      if (t.type == 'expense') {
        expenseMap[t.category] = (expenseMap[t.category] ?? 0) + t.amount;
      } else {
        final cat = t.category.isEmpty ? 'Lainnya' : t.category;
        incomeMap[cat] = (incomeMap[cat] ?? 0) + t.amount;
      }
    }

    final expSummary = expenseMap.entries
        .map((e) => "${e.key}: ${CurrencyFormatter.format(e.value)}")
        .join(', ');
    final incSummary = incomeMap.entries
        .map((e) => "${e.key}: ${CurrencyFormatter.format(e.value)}")
        .join(', ');

    return '''WAKTU: ${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB | Sisa $daysRemaining hari

KEUANGAN:
Pemasukan tetap: ${CurrencyFormatter.format(grossIncome)} | Gajian: ${paydayInfo.isEmpty ? 'N/A' : paydayInfo}
Pemasukan tercatat bulan ini: ${CurrencyFormatter.format(monthlyIncome)} [${incSummary.isEmpty ? '-' : incSummary}]
Cicilan: ${CurrencyFormatter.format(cicilan)} (jatuh tempo tgl ${profile?.cicilanDueDay ?? 'N/A'})
Budget bebas: ${CurrencyFormatter.format(freeBudget)}
Pengeluaran bulan ini: ${CurrencyFormatter.format(totalExpense)} [${expSummary.isEmpty ? '-' : expSummary}]
Tersisa: ${CurrencyFormatter.format(remainingBudget)} | Limit harian: ${CurrencyFormatter.format(dailyLimit)}
Skor kesehatan: $healthScore/100''';
  }

  // ── TRANSACTION LOG (max 30 terbaru, format ringkas) ──
  String _buildTransactionLog() {
    final transactions = _ref.read(transactionProvider);
    final now = DateTime.now();

    final monthly =
        transactions
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (monthly.isEmpty) return 'LOG TRANSAKSI: Belum ada transaksi bulan ini.';

    final capped = monthly.take(30);

    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    final lines = capped
        .map((t) {
          final d =
              '${t.date.day.toString().padLeft(2, '0')} ${monthNames[t.date.month - 1]}';
          final type = t.type == 'expense' ? 'KELUAR' : 'MASUK';
          final note = (t.note != null && t.note!.isNotEmpty)
              ? '"${t.note}"'
              : '';
          return '[$d] $type ${t.category} $note ${CurrencyFormatter.format(t.amount)}';
        })
        .join('\n');

    return 'LOG TRANSAKSI (${monthly.length} item, terbaru dulu):\n$lines';
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    state = [
      ...state,
      ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
    ];

    isLoading = true;
    state = [...state];

    // Build context
    final snapshot = _buildFinancialSnapshot();
    final txLog = _buildTransactionLog();

    // Generate cache key from question + financial snapshot hash
    final cacheInput = '$message|$snapshot';
    final cacheKey = md5.convert(utf8.encode(cacheInput)).toString();

    // 1. Check cache
    final cacheRepo = AiCacheRepository();
    final cached = cacheRepo.getCachedResponse(cacheKey);
    if (cached != null) {
      isLoading = false;
      state = [
        ...state,
        ChatMessage(text: cached, isUser: false, timestamp: DateTime.now()),
      ];
      return;
    }

    // 2. Check RPD limit
    if (!RpdCounter.canMakeRequest) {
      isLoading = false;
      state = [
        ...state,
        ChatMessage(
          text:
              "Kuota harian API sudah habis (${RpdCounter.usedToday}/20). Coba lagi besok, atau tambahkan API key baru di Pengaturan.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
      return;
    }

    // 3. Call API
    final systemContext = '${_buildPersona()}\n\n$snapshot';
    final userPrompt = '$txLog\n\nPertanyaan: $message';

    try {
      final responseText = await _geminiService.askAdvisor(
        userPrompt,
        systemContext: systemContext,
      );

      // Increment RPD counter
      await RpdCounter.increment();

      // Save to cache
      await cacheRepo.cacheResponse(cacheKey, responseText);

      isLoading = false;
      state = [
        ...state,
        ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (e) {
      isLoading = false;
      state = [
        ...state,
        ChatMessage(
          text:
              "Maaf, terjadi kesalahan atau koneksi terputus. Coba lagi nanti.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}
