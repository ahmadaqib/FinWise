import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import '../models/ai_cache.dart';
import '../../core/constants/app_constants.dart';

class AiCacheRepository {
  static const String boxName = AppConstants.boxAiCache;

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<AiCache>(boxName);
    }
    await cleanExpired();
  }

  Box<AiCache> get _box => Hive.box<AiCache>(boxName);

  /// Get cached response if still valid.
  /// Access updates LRU timestamp lazily.
  String? getCachedResponse(String cacheKey) {
    final entry = _box.get(cacheKey);
    if (entry == null) return null;
    if (entry.isExpired) {
      _box.delete(cacheKey);
      return null;
    }

    final now = DateTime.now();
    if (now.difference(entry.lastAccessedAt).inMinutes >= 1) {
      unawaited(_box.put(cacheKey, entry.copyWith(lastAccessedAt: now)));
    }

    return entry.response;
  }

  /// Save a response to cache with LRU eviction.
  Future<void> cacheResponse(
    String cacheKey,
    String response, {
    int? ttlMinutes,
  }) async {
    await cleanExpired();

    // Evict least recently used entries if at capacity.
    if (_box.length >= AppConstants.maxCacheEntries) {
      final entries = _box.values.toList()
        ..sort((a, b) {
          final byLastAccess = a.lastAccessedAt.compareTo(b.lastAccessedAt);
          if (byLastAccess != 0) return byLastAccess;
          return a.createdAt.compareTo(b.createdAt);
        });
      final toRemove = entries.take(
        _box.length - AppConstants.maxCacheEntries + 1,
      );
      for (final entry in toRemove) {
        await _box.delete(entry.cacheKey);
      }
    }

    final now = DateTime.now();
    await _box.put(
      cacheKey,
      AiCache(
        cacheKey: cacheKey,
        response: response,
        createdAt: now,
        ttlMinutes: ttlMinutes ?? AppConstants.cacheTtlMinutes,
        lastAccessedAt: now,
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
