import 'package:hive/hive.dart';
import 'income_change_log.dart';

part 'income_source.g.dart';

@HiveType(typeId: 1)
class IncomeSource extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double amount;

  @HiveField(3)
  String type; // 'fixed_monthly' | 'variable_monthly' | 'one_time' | 'passive'

  @HiveField(4)
  int receivedOnDay;

  @HiveField(5)
  bool isActive;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? deactivatedAt;

  @HiveField(8)
  List<IncomeChangeLog> changeLog;

  @HiveField(9, defaultValue: 'E')
  String quadrant; // 'E' | 'S' | 'B' | 'I'

  IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.type,
    required this.receivedOnDay,
    this.isActive = true,
    required this.createdAt,
    this.deactivatedAt,
    this.changeLog = const [],
    this.quadrant = 'E',
  });
}
