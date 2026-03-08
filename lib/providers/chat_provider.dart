import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/gemini_service.dart';
import '../services/ai_tools.dart';
import '../services/ai_action_executor.dart';
import '../data/repositories/user_profile_repository.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../core/utils/currency_formatter.dart';
import '../features/ai_advisor/widgets/action_confirmation_card.dart';
import 'budget_provider.dart';
import 'income_provider.dart';
import 'transaction_provider.dart';
import 'rpd_counter_provider.dart';
import 'cicilan_provider.dart';
import '../data/repositories/cicilan_repository.dart';

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((
  ref,
) {
  final geminiService = ref.read(geminiServiceProvider);
  return ChatNotifier(geminiService, ref);
});

/// A chat message — either plain text or an action card.
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  // Action-related fields (null for plain text messages)
  final PendingAction? action;
  final ActionCardStatus actionStatus;
  final String? actionId; // Unique ID for this action message

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
    this.actionStatus = ActionCardStatus.pending,
    this.actionId,
  });

  bool get isAction => action != null;

  ChatMessage copyWith({String? text, ActionCardStatus? actionStatus}) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser,
      timestamp: timestamp,
      action: action,
      actionStatus: actionStatus ?? this.actionStatus,
      actionId: actionId,
    );
  }
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _geminiService;
  final Ref _ref;
  bool isLoading = false;

  ChatNotifier(this._geminiService, this._ref)
    : super([
        ChatMessage(
          text:
              "Halo! Saya FinWise AI Advisor Anda. Saya bisa membantu menganalisis keuangan dan juga mencatat transaksi, mengatur gaji, serta mengelola cicilan langsung dari sini. Ada yang bisa saya bantu?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);

  // ── PERSONA ──
  String _buildPersona() {
    return '''Anda adalah FinWise AI — penasihat keuangan pribadi dengan pola pikir Warren Buffett dan kejelian analis keuangan berpengalaman 80 tahun.
Kepribadian: Tegas, to-the-point, berbasis data, selalu prioritaskan keamanan modal sebelum pertumbuhan.

KEMAMPUAN ANALISIS:
1. Kamu memiliki akses pengetahuan mendalam tentang kondisi pasar global, harga emas, pergerakan saham, dan tren geopolitik.
2. Selalu sertakan konteks ekonomi terkini (misal: inflasi, suku bunga, ketegangan geopolitik) saat memberikan saran investasi atau analisis aset.
3. Fokus pada perlindungan nilai (hedging) dan diversifikasi yang cerdas.

ATURAN KETAT:
1. DILARANG mengulang data keuangan user kecuali ditanya spesifik.
2. DILARANG basa-basi. LANGSUNG ke inti jawaban.
3. Jawaban MAKSIMAL 3 poin ringkas.
4. Untuk saran investasi WAJIB sertakan:
   a. Nominal Rupiah ideal (dari "Uang Tersisa" dikurangi dana darurat 20%).
   b. 1-2 instrumen spesifik dengan alasan berdasarkan tren makroekonomi/geopolitik saat ini.
   c. Persentase alokasi (misal: 60% reksadana, 40% SBN).
5. Jika skor < 50 atau cicilan > 40% income: TOLAK saran investasi, suruh perbaiki fundamental.
6. Gunakan bahasa kasual Indonesia.

KEMAMPUAN AKSI DATA:
Kamu punya kemampuan untuk mencatat dan mengubah data keuangan user melalui function tools.
- Kamu bisa: menambah transaksi, menambah/mengubah sumber pendapatan, menambah/mengubah cicilan, mencatat pembayaran cicilan.
- Kamu TIDAK bisa menghapus data apapun.
- Jika informasi yang diberikan user KURANG untuk melakukan aksi, TANYA dulu sebelum memanggil function.
- Setelah function dipanggil dan dikonfirmasi user, berikan respons singkat tentang dampaknya terhadap kondisi keuangan.''';
  }

  // ── FINANCIAL SNAPSHOT ──
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

    final transactions = _ref.read(transactionProvider);
    final monthlyIncome = transactions
        .where(
          (t) =>
              t.type == 'income' &&
              t.date.year == now.year &&
              t.date.month == now.month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

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

    // Cicilan details
    final activeCicilans = _ref.read(cicilanListProvider);
    final cicilanDetails = activeCicilans
        .map((c) {
          final paid = CicilanRepository().getPaidCount(c.id);
          return '${c.name}: ${CurrencyFormatter.format(c.monthlyAmount)}/bln (${paid}/${c.totalTenor}x, jatuh tempo tgl ${c.dueDay})';
        })
        .join('\n');

    return '''WAKTU: ${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year} | ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB | Sisa $daysRemaining hari

KEUANGAN:
Pemasukan tetap: ${CurrencyFormatter.format(grossIncome)} | Gajian: ${paydayInfo.isEmpty ? 'N/A' : paydayInfo}
Pemasukan tercatat bulan ini: ${CurrencyFormatter.format(monthlyIncome)} [${incSummary.isEmpty ? '-' : incSummary}]
Cicilan total: ${CurrencyFormatter.format(cicilan)} (jatuh tempo tgl ${profile?.cicilanDueDay ?? 'N/A'})
${cicilanDetails.isNotEmpty ? 'Detail cicilan:\n$cicilanDetails' : 'Belum ada cicilan aktif.'}
Budget bebas: ${CurrencyFormatter.format(freeBudget)}
Pengeluaran bulan ini: ${CurrencyFormatter.format(totalExpense)} [${expSummary.isEmpty ? '-' : expSummary}]
Tersisa: ${CurrencyFormatter.format(remainingBudget)} | Limit harian: ${CurrencyFormatter.format(dailyLimit)}
Skor kesehatan: $healthScore/100''';
  }

  // ── TRANSACTION LOG ──
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

  /// Main entry: sends a message and handles both text and function-call responses.
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    state = [
      ...state,
      ChatMessage(text: message, isUser: true, timestamp: DateTime.now()),
    ];

    isLoading = true;
    state = [...state];

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
              "Kuota harian API sudah habis (${RpdCounter.usedToday}/20). Coba lagi besok.",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
      return;
    }

    final systemContext = '${_buildPersona()}\n\n$snapshot';
    final userPrompt = '$txLog\n\nPertanyaan: $message';

    try {
      // Use function-calling endpoint
      final response = await _geminiService.askAdvisorWithTools(
        userPrompt,
        systemContext: systemContext,
        tools: AiTools.tools,
      );

      await RpdCounter.increment();

      // Check if response contains a function call
      final candidate = response.candidates.first;
      final parts = candidate.content.parts;

      FunctionCall? functionCall;
      String? textResponse;

      for (final part in parts) {
        if (part is FunctionCall) {
          functionCall = part;
        } else if (part is TextPart) {
          textResponse = part.text;
        }
      }

      if (functionCall != null) {
        // AI wants to perform an action — show confirmation card
        final executor = AiActionExecutor(_ref);
        final pendingAction = executor.parseAction(
          functionCall.name,
          functionCall.args,
        );

        final actionId =
            '${functionCall.name}_${DateTime.now().millisecondsSinceEpoch}';

        isLoading = false;

        // If there's also text, show it first
        if (textResponse != null && textResponse.isNotEmpty) {
          state = [
            ...state,
            ChatMessage(
              text: textResponse,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ];
        }

        // Show action card
        state = [
          ...state,
          ChatMessage(
            text: '', // Not used for action cards
            isUser: false,
            timestamp: DateTime.now(),
            action: pendingAction,
            actionId: actionId,
          ),
        ];
      } else {
        // Plain text response
        final responseText =
            textResponse ?? response.text ?? 'Tidak ada respons.';

        // Cache the response
        final cacheInput = '$message|$snapshot';
        final cacheKey = md5.convert(utf8.encode(cacheInput)).toString();
        await AiCacheRepository().cacheResponse(cacheKey, responseText);

        isLoading = false;
        state = [
          ...state,
          ChatMessage(
            text: responseText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      }
    } catch (e) {
      // Fallback to text-only mode
      try {
        final systemContext = '${_buildPersona()}\n\n$snapshot';
        final userPrompt = '$txLog\n\nPertanyaan: $message';
        final fallbackText = await _geminiService.askAdvisor(
          userPrompt,
          systemContext: systemContext,
        );
        await RpdCounter.increment();

        isLoading = false;
        state = [
          ...state,
          ChatMessage(
            text: fallbackText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      } catch (_) {
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

  /// Confirm a pending action.
  Future<void> confirmAction(String actionId) async {
    final index = state.indexWhere((m) => m.actionId == actionId);
    if (index == -1) return;

    final msg = state[index];
    if (msg.action == null) return;

    // Update status to confirmed
    final updated = msg.copyWith(actionStatus: ActionCardStatus.confirmed);
    state = [...state]..[index] = updated;

    // Execute the action
    isLoading = true;
    state = [...state];

    final executor = AiActionExecutor(_ref);
    final result = await executor.execute(msg.action!);

    isLoading = false;

    // Add result message
    state = [
      ...state,
      ChatMessage(
        text: result.success ? '✅ ${result.summary}' : '❌ ${result.summary}',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }

  /// Cancel a pending action.
  void cancelAction(String actionId) {
    final index = state.indexWhere((m) => m.actionId == actionId);
    if (index == -1) return;

    final msg = state[index];
    final updated = msg.copyWith(actionStatus: ActionCardStatus.cancelled);
    state = [...state]..[index] = updated;

    state = [
      ...state,
      ChatMessage(
        text: 'Aksi dibatalkan. Ada yang lain?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
  }
}
