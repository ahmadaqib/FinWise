import 'package:hive/hive.dart';

part 'alert_config.g.dart';

@HiveType(typeId: 6)
class AlertConfig extends HiveObject {
  @HiveField(0)
  String alertType;

  @HiveField(1)
  double threshold;

  @HiveField(2)
  bool isEnabled;

  @HiveField(3)
  DateTime? lastTriggered;

  AlertConfig({
    required this.alertType,
    required this.threshold,
    this.isEnabled = true,
    this.lastTriggered,
  });
}
