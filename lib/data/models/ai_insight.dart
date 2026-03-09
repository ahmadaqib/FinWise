import 'package:hive/hive.dart';

part 'ai_insight.g.dart';

@HiveType(typeId: 12)
class AiInsight extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  String type; // 'warning' | 'opportunity' | 'achievement' | 'tip'

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  String? actionLabel;

  @HiveField(7)
  String? actionRoute;

  AiInsight({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionLabel,
    this.actionRoute,
  });
}
