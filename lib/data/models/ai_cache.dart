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

  AiCache({
    required this.cacheKey,
    required this.response,
    required this.createdAt,
    this.ttlMinutes = 360,
  });

  bool get isExpired =>
      DateTime.now().difference(createdAt).inMinutes > ttlMinutes;
}
