import 'package:hive/hive.dart';

part 'cicilan_payment.g.dart';

@HiveType(typeId: 9)
class CicilanPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String cicilanId;

  @HiveField(2)
  int paymentNumber; // Pembayaran ke-N (contoh: 3 dari 12)

  @HiveField(3)
  double amount;

  @HiveField(4)
  DateTime paidDate;

  @HiveField(5)
  String? note;

  CicilanPayment({
    required this.id,
    required this.cicilanId,
    required this.paymentNumber,
    required this.amount,
    required this.paidDate,
    this.note,
  });
}
