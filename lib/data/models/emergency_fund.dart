import 'package:hive/hive.dart';

part 'emergency_fund.g.dart';

@HiveType(typeId: 14)
class EmergencyFundEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final String source; // 'shield_carryover' | 'manual_deposit' | 'withdrawal'

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? note;

  EmergencyFundEntry({
    required this.id,
    required this.amount,
    required this.source,
    required this.date,
    this.note,
  });
}
