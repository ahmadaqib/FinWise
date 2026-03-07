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

  MonthlySummary({
    required this.month,
    required this.year,
    required this.totalIncome,
    required this.totalExpense,
    this.cicilanPaid = false,
    required this.saldo,
  });
}
