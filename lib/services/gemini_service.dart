import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../data/repositories/user_profile_repository.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  final UserProfileRepository _repo = UserProfileRepository();

  // Daftar model yang akan diputar (rotate model agar aman jika limit)
  final List<String> _models = [
    'gemini-2.5-flash', // Model generasi terbaru yang sangat cepat dan pintar
    'gemini-2.0-flash-lite', // Model ringan dan super cepat generasi 2
    'gemini-1.5-flash', // Fallback flash yang populer
    'gemini-1.5-pro', // Fallback untuk reasoning berat
    'gemini-1.5-flash-8b', // Fallback terakhir
  ];

  Future<List<String>> _getApiKeys() async {
    // Ambil kunci dari storage (jika diset lewat UI)
    String? storedKey = await _repo.getGeminiApiKey();

    // Gabung dengan hardcoded key dari repository
    String rawKeys =
        "${UserProfileRepository.hardcodedApiKeys},${storedKey ?? ''}";

    // Split dengan koma, bersihkan spasi, dan hapus yang kosong
    List<String> keys = rawKeys
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    return keys;
  }

  Future<String> askAdvisor(String prompt) async {
    final apiKeys = await _getApiKeys();

    if (apiKeys.isEmpty) {
      return "Anda belum mengatur Gemini API Key. Silakan masukkan di Pengaturan.";
    }

    // Strategi ROTASI: Coba kombinasi (Semua API Key) x (Semua Model)
    // Agar sangat aman dari error Rate Limit / Quota Exceeded (429)
    for (String apiKey in apiKeys) {
      for (String modelName in _models) {
        try {
          final model = GenerativeModel(model: modelName, apiKey: apiKey);

          final response = await model.generateContent([Content.text(prompt)]);

          if (response.text != null && response.text!.isNotEmpty) {
            return response.text!;
          }
        } catch (e) {
          final errorMessage = e.toString().toLowerCase();
          // Jika error adalah quota/rate limit (sebisa mungkin kita rotate API key/Model)
          if (errorMessage.contains('429') ||
              errorMessage.contains('quota') ||
              errorMessage.contains('exhausted')) {
            debugPrint(
              'Model $modelName dengan Key ini limit, mencoba rotasi...',
            );
            continue; // Coba model/key selanjutnya
          }

          // Jika error lain (misal offline/timeout), jangan langsung skip, tapi return error
          debugPrint('Gagal menghasilkan AI (bukan rate limit): $e');
        }
      }
    }

    return "Maaf, semua kombinasi API Key dan Model saat ini sedang limit/error. Coba lagi nanti atau tambahkan API key baru.";
  }
}
