import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 3)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String type; // 'income' | 'expense'

  @HiveField(3)
  String category;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  bool isRecurring;

  @HiveField(7)
  String? imageRef;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.date,
    this.isRecurring = false,
    this.imageRef,
  });
}
