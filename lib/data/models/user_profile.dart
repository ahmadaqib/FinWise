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

  UserProfile({
    required this.name,
    this.fixedIncome1 = 4750000,
    this.fixedIncome2 = 2500000,
    this.cicilanMonth1 = 3000000,
    this.cicilanNormal = 2000000,
    this.isMonth1 = true,
    this.cicilanDueDay = 24,
  });
}
