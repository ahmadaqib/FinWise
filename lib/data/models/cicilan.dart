import 'package:hive/hive.dart';

part 'cicilan.g.dart';

@HiveType(typeId: 8)
class Cicilan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double totalAmount;

  @HiveField(3)
  double monthlyAmount;

  @HiveField(4)
  int totalTenor; // Total bulan cicilan (12x, 24x, dst)

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  int dueDay; // Tanggal jatuh tempo tiap bulan (1-31)

  @HiveField(7)
  bool isActive;

  @HiveField(8)
  String? note;

  Cicilan({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.monthlyAmount,
    required this.totalTenor,
    required this.startDate,
    required this.dueDay,
    this.isActive = true,
    this.note,
  });
}
