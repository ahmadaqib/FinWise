import 'package:hive/hive.dart';

part 'ai_cache.g.dart';

@HiveType(typeId: 10)
class AiCache extends HiveObject {
  @HiveField(0)
  final String cacheKey;

  @HiveField(1)
  final String response;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final int ttlMinutes;

  @HiveField(4)
  final DateTime lastAccessedAt;

  AiCache({
    required this.cacheKey,
    required this.response,
    required this.createdAt,
    this.ttlMinutes = 360,
    DateTime? lastAccessedAt,
  }) : lastAccessedAt = lastAccessedAt ?? createdAt;

  bool get isExpired =>
      DateTime.now().difference(createdAt).inMinutes > ttlMinutes;

  AiCache copyWith({String? response, DateTime? lastAccessedAt}) {
    return AiCache(
      cacheKey: cacheKey,
      response: response ?? this.response,
      createdAt: createdAt,
      ttlMinutes: ttlMinutes,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }
}
