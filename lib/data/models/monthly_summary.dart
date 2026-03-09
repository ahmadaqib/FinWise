import 'package:hive/hive.dart';

part 'monthly_summary.g.dart';

@HiveType(typeId: 5)
class MonthlySummary extends HiveObject {
  @HiveField(0)
  int month;

  @HiveField(1)
  int year;

  @HiveField(2)
  double totalIncome;

  @HiveField(3)
  double totalExpense;

  @HiveField(4)
  bool cicilanPaid;

  @HiveField(5)
  double saldo;

  @HiveField(6)
  double? fwsScore;

  @HiveField(7)
  double? zoneShieldSpent;

  @HiveField(8)
  double? zoneFlowSpent;

  @HiveField(9)
  double? zoneGrowSpent;

  @HiveField(10)
  double? zoneFreeSpent;

  @HiveField(11)
  DateTime? startDate;

  @HiveField(12)
  DateTime? endDate;

  MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    this.cicilanPaid = false,
    required this.saldo,
    this.fwsScore,
    this.zoneShieldSpent,
    this.zoneFlowSpent,
    this.zoneGrowSpent,
    this.zoneFreeSpent,
    this.startDate,
    this.endDate,
  });
}
