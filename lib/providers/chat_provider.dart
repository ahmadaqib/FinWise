import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/gemini_service.dart';
import '../services/ai_tools.dart';
import '../services/ai_action_executor.dart';
import '../data/repositories/ai_cache_repository.dart';
import '../core/utils/currency_formatter.dart';
import '../features/ai_advisor/widgets/action_confirmation_card.dart';
import 'budget_provider.dart';
import 'transaction_provider.dart';
import 'rpd_counter_provider.dart';

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
78: Kepribadian: Tegas, to-the-point, berbasis data, selalu prioritaskan keamanan modal sebelum pertumbuhan.

KEMAMPUAN ANALISIS:
1. Kamu memiliki akses pengetahuan mendalam tentang kondisi pasar global dan algoritma FinWise 5-Layer.
2. Selalu gunakan metrik FWS (FinWise Score) dan Spending Velocity dalam analisismu.
3. Fokus pada perlindungan nilai (hedging) dan diversifikasi yang cerdas berdasarkan Cash Flow Quadrant user.

ATURAN KETAT:
1. DILARANG mengulang data keuangan user kecuali ditanya spesifik.
2. DILARANG basa-basi. LANGSUNG ke inti jawaban.
3. Jawaban MAKSIMAL 3 poin ringkas.
4. Gunakan metrik "Adaptive Daily Limit" saat user bertanya tentang budget harian.
5. Jika FWS < 400 (Fragile/Surviving): Fokus pada fundamental (Layer 1 FLOW).
6. Gunakan bahasa kasual Indonesia.''';
  }

  // ── FINANCIAL SNAPSHOT ──
  String _buildFinancialSnapshot() {
    final context = _ref.read(aiContextPackageProvider);
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = daysInMonth - now.day;

    String fmt(double val) => CurrencyFormatter.format(val);
    String pct(double val) => "${val.toStringAsFixed(1)}%";

    return '''WAKTU: ${now.day}/${now.month}/${now.year} | Sisa $daysRemaining hari

KONTEKS FINWISE (5-LAYER ENGINE):
[LAYER 1: FLOW]
Score Efisiensi: ${pct(context.flowScore)}
Adaptive Daily Limit: ${fmt(context.adaptiveDailySafeLimit)}
Sisa Budget Bebas: ${fmt(context.remainingBudget)}
Zona: S/F/G/F: ${fmt(context.zoneDistribution['shield'] ?? 0)} / ${fmt(context.zoneDistribution['flow'] ?? 0)} / ${fmt(context.zoneDistribution['grow'] ?? 0)} / ${fmt(context.zoneDistribution['free'] ?? 0)}

[LAYER 2: QUADRANT]
Freedom Index: ${context.freedomIndex.toStringAsFixed(2)}/100
Distribusi: E:${fmt(context.incomeByQuadrant['E'] ?? 0)}, S:${fmt(context.incomeByQuadrant['S'] ?? 0)}, B:${fmt(context.incomeByQuadrant['B'] ?? 0)}, I:${fmt(context.incomeByQuadrant['I'] ?? 0)}

[LAYER 3: BEHAVIOR]
Spending Velocity: ${context.spendingVelocity.toStringAsFixed(2)}x (ideal 1.0)
Impulse Rate: ${pct(context.impulseRateOverall * 100)}
Asset/Liability Ratio: ${context.assetToLiabilityRatio.toStringAsFixed(2)}

[LAYER 4: FWS SCORE]
FWS: ${context.currentFWS.toInt()}/1000 (${context.fwsBand})

[LAYER 5: ANCHOR]
Emergency Fund: ${pct(context.emergencyFundProgress)}
Anchor Score: ${context.enoughAnchorScore.toStringAsFixed(1)}/100''';
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
