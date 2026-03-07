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
    'gemini-2.5-flash', // Prioritas utama (cepat + kualitas tinggi)
    'gemini-2.0-flash', // Fallback seri 2 yang umum
    'gemini-2.0-flash-exp', // Fallback experimental
    'gemini-2.0-flash-lite', // Fallback ringan
    'gemma-3-1b-it', // Fallback Gemma (instruction-tuned)
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
}
