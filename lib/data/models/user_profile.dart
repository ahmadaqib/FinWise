import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double fixedIncome1;

  @HiveField(2)
  double fixedIncome2;

  @HiveField(3)
  double cicilanMonth1;

  @HiveField(4)
  double cicilanNormal;

  @HiveField(5)
  bool isMonth1;

  @HiveField(6, defaultValue: 24)
  int cicilanDueDay; // Tanggal jatuh tempo cicilan (1-31)

  @HiveField(7, defaultValue: 15000000)
  double emergencyFundTarget;

  @HiveField(8, defaultValue: 5000000)
  double monthlyPassiveTarget;

  @HiveField(9, defaultValue: 100000000)
  double netWorthTarget;

  @HiveField(10, defaultValue: 25)
  int salaryDate; // Tanggal gajian (1-31)

  @HiveField(11)
  DateTime? lastArchivedDate;

  UserProfile({
    required this.name,
    this.fixedIncome1 = 4750000,
    this.fixedIncome2 = 2500000,
    this.cicilanMonth1 = 3000000,
    this.cicilanNormal = 2000000,
    this.isMonth1 = true,
    this.cicilanDueDay = 24,
    this.emergencyFundTarget = 15000000,
    this.monthlyPassiveTarget = 5000000,
    this.netWorthTarget = 100000000,
    this.salaryDate = 25,
    this.lastArchivedDate,
  });
}
