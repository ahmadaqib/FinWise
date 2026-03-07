import 'package:hive/hive.dart';

part 'side_project.g.dart';

@HiveType(typeId: 7)
class SideProject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String source;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  Map<String, double> allocation; // e.g., {'tabungan': 400000, 'kebutuhan': 200000, 'investasi': 200000}

  SideProject({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    required this.allocation,
  });
}
