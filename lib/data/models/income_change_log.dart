import 'package:hive/hive.dart';

part 'income_change_log.g.dart';

@HiveType(typeId: 2)
class IncomeChangeLog extends HiveObject {
  @HiveField(0)
  double oldAmount;

  @HiveField(1)
  double newAmount;

  @HiveField(2)
  DateTime changedAt;

  @HiveField(3)
  String? reason;

  IncomeChangeLog({
    required this.oldAmount,
    required this.newAmount,
    required this.changedAt,
    this.reason,
  });
}
