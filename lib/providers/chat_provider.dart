import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/gemini_service.dart';
import '../services/macro_context_service.dart';
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
    return '''Anda adalah FinWise AI Advisor, partner keuangan pribadi yang human, jelas, dan berbasis data.

GAYA KOMUNIKASI:
1. Gunakan bahasa Indonesia kasual-profesional, natural seperti advisor manusia.
2. Jawab inti pertanyaan dulu dalam 1-2 kalimat, lalu jelaskan sebab-akibatnya.
3. Sampaikan insight yang seimbang: risiko, peluang, dan langkah aksi.
4. Jika ada peringatan, jelaskan alasan angka dan dampaknya, bukan hanya label warning.
5. Hindari jawaban terlalu pendek yang tidak memberi konteks.

ATURAN ANALISIS:
1. Utamakan konteks percakapan terbaru dan data finansial user saat ini.
2. Gunakan metrik FinWise saat relevan: Adaptive Daily Limit, Spending Velocity, FWS, dan Flow Score.
3. Jangan menyalin semua data mentah; pilih 2-4 angka paling penting.
4. Jika user meminta strategi, berikan minimal 2 opsi dengan trade-off singkat.
5. Jika data kurang, tulis asumsi dengan jujur dalam 1 kalimat.
6. Jika user meminta pencatatan/update data, gunakan tool function-calling yang sesuai.''';
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
  String _buildTransactionLog({int maxItems = 12}) {
    final transactions = _ref.read(transactionProvider);
    final now = DateTime.now();

    final monthly =
        transactions
            .where((t) => t.date.year == now.year && t.date.month == now.month)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    if (monthly.isEmpty) return 'LOG TRANSAKSI: Belum ada transaksi bulan ini.';

    final capped = monthly.take(maxItems);

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

    return 'LOG TRANSAKSI (${monthly.length} item, dikirim ${capped.length} terbaru):\n$lines';
  }

  String _buildConversationContext({int maxTurns = 10}) {
    final plainMessages = state
        .where((m) => !m.isAction && m.text.trim().isNotEmpty)
        .toList();

    if (plainMessages.isEmpty) {
      return 'RIWAYAT PERCAKAPAN: (kosong)';
    }

    // The latest user message is sent separately as "Pertanyaan terbaru".
    if (plainMessages.last.isUser) {
      plainMessages.removeLast();
    }

    if (plainMessages.isEmpty) {
      return 'RIWAYAT PERCAKAPAN: (belum ada konteks sebelumnya)';
    }

    final recent = plainMessages.length <= maxTurns
        ? plainMessages
        : plainMessages.sublist(plainMessages.length - maxTurns);

    final lines = recent
        .map((m) {
          final role = m.isUser ? 'USER' : 'AI';
          final text = _singleLine(m.text, maxChars: 240);
          return '[$role] $text';
        })
        .join('\n');

    return 'RIWAYAT PERCAKAPAN TERBARU:\n$lines';
  }

  bool _needsGlobalMacroContext(String message) {
    final lower = message.toLowerCase();
    const primaryKeywords = [
      'politik',
      'ekonomi global',
      'ekonomi dunia',
      'makro',
      'geopolitik',
      'inflasi',
      'resesi',
      'suku bunga',
      'bank sentral',
      'the fed',
      'fed',
      'ecb',
      'perang',
      'tarif',
      'sanksi',
      'election',
      'pemilu',
      'berita terbaru',
      'update dunia',
      'harga minyak',
      'pasar saham dunia',
      'dollar',
      'usd',
    ];
    if (primaryKeywords.any(lower.contains)) {
      return true;
    }

    const geoKeywords = [
      'amerika',
      'china',
      'eropa',
      'rusia',
      'ukraina',
      'iran',
    ];
    const impactKeywords = [
      'ekonomi',
      'pasar',
      'inflasi',
      'suku bunga',
      'investasi',
      'rupiah',
      'saham',
      'obligasi',
      'komoditas',
      'minyak',
      'tarif',
      'sanksi',
    ];

    return geoKeywords.any(lower.contains) &&
        impactKeywords.any(lower.contains);
  }

  bool _needsDetailedTransactionLog(String message) {
    final lower = message.toLowerCase();
    const detailKeywords = [
      'riwayat transaksi',
      'transaksi terakhir',
      'detail transaksi',
      'list transaksi',
      'pengeluaran bulan ini',
      'kategori pengeluaran',
      'rekap transaksi',
      'histori transaksi',
    ];
    return detailKeywords.any(lower.contains);
  }

  Future<String?> _buildGlobalMacroContext(String message) async {
    if (!_needsGlobalMacroContext(message)) {
      return null;
    }

    try {
      final snapshot = await _ref
          .read(macroContextServiceProvider)
          .fetchLatest()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (snapshot == null || snapshot.headlines.isEmpty) {
        return null;
      }

      return snapshot.toPromptBlock(maxItems: 6);
    } catch (_) {
      return null;
    }
  }

  String _singleLine(String input, {int maxChars = 200}) {
    final compact = input.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= maxChars) return compact;
    return '${compact.substring(0, maxChars)}...';
  }

  bool _isGeminiServiceError(String response) {
    final lower = response.toLowerCase();
    return lower.contains('belum mengatur gemini api key') ||
        lower.contains('semua kombinasi api key') ||
        lower.contains('sedang limit/error');
  }

  String _composeUserPrompt({
    required String conversationContext,
    required String transactionLog,
    required String latestMessage,
    String? globalMacroContext,
  }) {
    final macroBlock = globalMacroContext == null
        ? ''
        : '\n\n$globalMacroContext\n'
              'Gunakan konteks global hanya jika relevan dengan pertanyaan user.';

    return '$conversationContext\n\n$transactionLog$macroBlock\n\n'
        'Pertanyaan terbaru user: $latestMessage\n\n'
        'FORMAT RESPONS (jika tidak sedang memanggil tool):\n'
        '1) Inti jawaban: 1-2 kalimat langsung menjawab pertanyaan.\n'
        '2) Insight berbasis data: 2-3 poin dengan alasan singkat.\n'
        '3) Aksi praktis 24 jam: 1 langkah paling berdampak.';
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
    final txLog = _buildTransactionLog(
      maxItems: _needsDetailedTransactionLog(message) ? 30 : 12,
    );
    final txLogDigest = md5.convert(utf8.encode(txLog)).toString();
    final conversationContext = _buildConversationContext(maxTurns: 10);
    final needsMacroContext = _needsGlobalMacroContext(message);
    final utcNow = DateTime.now().toUtc();
    final macroCacheSlice = needsMacroContext
        ? '${utcNow.year}-${utcNow.month}-${utcNow.day}-${utcNow.hour}'
        : 'none';

    // Generate cache key from question + financial snapshot + conversation
    final cacheInput =
        'v2|$message|$snapshot|tx:$txLogDigest|$conversationContext|macro:$macroCacheSlice';
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

    final globalMacroContext = await _buildGlobalMacroContext(message);
    final systemContext = '${_buildPersona()}\n\n$snapshot';
    final userPrompt = _composeUserPrompt(
      conversationContext: conversationContext,
      transactionLog: txLog,
      latestMessage: message,
      globalMacroContext: globalMacroContext,
    );

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
      }
    } catch (e) {
      // Fallback to text-only mode
      try {
        final fallbackText = await _geminiService.askAdvisor(
          userPrompt,
          systemContext: systemContext,
        );
        if (!_isGeminiServiceError(fallbackText)) {
          await RpdCounter.increment();
          await cacheRepo.cacheResponse(cacheKey, fallbackText);
        }

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
