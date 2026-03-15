import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_cache.dart';
import '../../core/constants/app_constants.dart';

class AiCacheRepository {
  static const String boxName = AppConstants.boxAiCache;

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<AiCache>(boxName);
    }
  }

  Box<AiCache> get _box => Hive.box<AiCache>(boxName);

  /// Get cached response if still valid
  String? getCachedResponse(String cacheKey) {
    final entry = _box.get(cacheKey);
    if (entry == null) return null;
    if (entry.isExpired) {
      _box.delete(cacheKey);
      return null;
    }
    return entry.response;
  }

  /// Save a response to cache with FIFO eviction
  Future<void> cacheResponse(
    String cacheKey,
    String response, {
    int? ttlMinutes,
  }) async {
    // Evict oldest entries if at capacity
    if (_box.length >= AppConstants.maxCacheEntries) {
      final entries = _box.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final toRemove = entries.take(
        _box.length - AppConstants.maxCacheEntries + 1,
      );
      for (final entry in toRemove) {
        await _box.delete(entry.cacheKey);
      }
    }

    await _box.put(
      cacheKey,
      AiCache(
        cacheKey: cacheKey,
        response: response,
        createdAt: DateTime.now(),
        ttlMinutes: ttlMinutes ?? AppConstants.cacheTtlMinutes,
      ),
    );
  }

  /// Invalidate all cache entries (called when new transaction is added)
  Future<void> invalidateAll() async {
    await _box.clear();
  }

  /// Clean up expired entries
  Future<void> cleanExpired() async {
    final expiredKeys = _box.values
        .where((e) => e.isExpired)
        .map((e) => e.cacheKey)
        .toList();
    for (final key in expiredKeys) {
      await _box.delete(key);
    }
  }
}
