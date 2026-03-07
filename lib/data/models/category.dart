import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String icon;

  @HiveField(3)
  String color;

  @HiveField(4)
  double? budgetLimit;

  @HiveField(5)
  bool isDefault;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.budgetLimit,
    this.isDefault = false,
  });
}
