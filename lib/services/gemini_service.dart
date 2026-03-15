import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/repositories/user_profile_repository.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  final UserProfileRepository _repo = UserProfileRepository();
  static const int _maxOutputTokensText = 1600;
  static const int _maxOutputTokensFunctionCall = 1200;

  // Daftar model yang akan diputar (rotate model agar aman jika limit)
  final List<String> _models = [
    'gemini-2.5-flash', // Prioritas utama (cepat + kualitas tinggi)
    'gemini-2.0-flash', // Fallback seri 2 yang umum
    'gemini-2.0-flash-exp', // Fallback experimental
    'gemini-2.0-flash-lite', // Fallback ringan
    'gemma-3-1b-it', // Fallback Gemma (instruction-tuned)
  ];

  Future<List<String>> _getApiKeys() async {
    // Seluruh API key diambil dari secure storage.
    // Jika user memasukkan beberapa key dipisah koma, semuanya akan dipakai.
    final rawKeys = await _repo.getGeminiApiKey() ?? '';

    // Split dengan koma, bersihkan spasi, dan hapus yang kosong
    final keys = rawKeys
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    return keys;
  }

  Future<String> askAdvisor(String userMessage, {String? systemContext}) async {
    final apiKeys = await _getApiKeys();

    if (apiKeys.isEmpty) {
      return "Anda belum mengatur Gemini API Key. Silakan masukkan di Pengaturan.";
    }

    // Strategi ROTASI: Coba kombinasi (Semua API Key) x (Semua Model)
    for (String apiKey in apiKeys) {
      for (String modelName in _models) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
            systemInstruction: systemContext != null
                ? Content.text(systemContext)
                : null,
            generationConfig: GenerationConfig(
              maxOutputTokens: _maxOutputTokensText,
              temperature: 0.45,
            ),
          );

          final response = await model.generateContent([
            Content.text(userMessage),
          ]);

          if (response.text != null && response.text!.isNotEmpty) {
            return response.text!;
          }
        } catch (e) {
          final errorMessage = e.toString().toLowerCase();
          // Jika error adalah quota/rate limit, lanjut rotasi key/model.
          if (errorMessage.contains('429') ||
              errorMessage.contains('quota') ||
              errorMessage.contains('exhausted')) {
            debugPrint(
              'Model $modelName dengan Key ini limit, mencoba rotasi...',
            );
            continue; // Coba model/key selanjutnya
          }

          // Model tidak tersedia/unsupported untuk versi API tertentu -> rotasi saja.
          if (errorMessage.contains('not found for api version') ||
              errorMessage.contains('is not supported for generatecontent') ||
              errorMessage.contains('unsupported')) {
            debugPrint(
              'Model $modelName tidak tersedia, mencoba model lain...',
            );
            continue;
          }

          // Error lain (misal offline/timeout) dicatat, lalu tetap coba kombinasi lain.
          debugPrint('Gagal menghasilkan AI (bukan rate limit): $e');
        }
      }
    }

    return "Maaf, semua kombinasi API Key dan Model saat ini sedang limit/error. Coba lagi nanti atau tambahkan API key baru.";
  }

  /// Ask advisor with function calling tools enabled.
  /// Returns the raw GenerateContentResponse so caller can inspect
  /// whether it contains text or a FunctionCall.
  Future<GenerateContentResponse> askAdvisorWithTools(
    String userMessage, {
    String? systemContext,
    required List<Tool> tools,
  }) async {
    final apiKeys = await _getApiKeys();

    if (apiKeys.isEmpty) {
      throw Exception('No API keys configured');
    }

    // Only use models that support function calling (gemini-2.0-flash+)
    final fcModels = ['gemini-2.5-flash', 'gemini-2.0-flash'];

    for (String apiKey in apiKeys) {
      for (String modelName in fcModels) {
        try {
          final model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
            systemInstruction: systemContext != null
                ? Content.text(systemContext)
                : null,
            tools: tools,
            generationConfig: GenerationConfig(
              maxOutputTokens: _maxOutputTokensFunctionCall,
              temperature: 0.25,
            ),
          );

          final response = await model.generateContent([
            Content.text(userMessage),
          ]);

          return response;
        } catch (e) {
          final errorMessage = e.toString().toLowerCase();
          if (errorMessage.contains('429') ||
              errorMessage.contains('quota') ||
              errorMessage.contains('exhausted') ||
              errorMessage.contains('not found for api version') ||
              errorMessage.contains('unsupported')) {
            debugPrint('FC model $modelName rotasi: $e');
            continue;
          }
          debugPrint('FC error (non-recoverable): $e');
        }
      }
    }

    throw Exception(
      'Semua kombinasi API Key dan Model gagal untuk function calling.',
    );
  }
}
