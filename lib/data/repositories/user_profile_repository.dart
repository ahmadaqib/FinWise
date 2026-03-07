import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  static const String boxName = 'user_profile';
  static const String profileKey = 'main_profile';
  static const String _geminiApiKeyStorageKey =
      'gemini_api_key'; // Ini JANGAN diisi API key, ini cuma NAMA KUNCI penyimpanan

  // Anda bisa menaruh default/hardcoded API key(s) di sini dipisah koma untuk rotasi
  static const String hardcodedApiKeys =
      'AIzaSyADbtUw7nYi0rosPd9lVUdQskQ8K2wzfJU';

  final _secureStorage = const FlutterSecureStorage();

  Box<UserProfile> get _box => Hive.box<UserProfile>(boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<UserProfile>(boxName);
    }
  }

  UserProfile? getProfile() {
    return _box.get(profileKey);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _box.put(profileKey, profile);
  }

  bool hasProfile() {
    return _box.containsKey(profileKey);
  }

  // Gemini API Key Management
  Future<void> saveGeminiApiKey(String apiKey) async {
    await _secureStorage.write(key: _geminiApiKeyStorageKey, value: apiKey);
  }

  Future<String?> getGeminiApiKey() async {
    return await _secureStorage.read(key: _geminiApiKeyStorageKey);
  }

  Future<void> deleteGeminiApiKey() async {
    await _secureStorage.delete(key: _geminiApiKeyStorageKey);
  }
}
