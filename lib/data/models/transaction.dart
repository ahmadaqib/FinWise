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

  Transaction copyWith({
    String? id,
    double? amount,
    String? type,
    String? category,
    String? note,
    DateTime? date,
    bool? isRecurring,
    String? imageRef,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      imageRef: imageRef ?? this.imageRef,
    );
  }
}
