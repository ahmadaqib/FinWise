import 'package:hive_flutter/hive_flutter.dart';
import '../models/alert_config.dart';

class AlertRepository {
  static const String boxName = 'alert_configs';

  Box<AlertConfig> get _box => Hive.box<AlertConfig>(boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<AlertConfig>(boxName);
    }
  }

  AlertConfig getConfig(String id, {double threshold = 0.0}) {
    return _box.get(id) ??
        AlertConfig(alertType: id, threshold: threshold, isEnabled: true);
  }

  Future<void> saveConfig(AlertConfig config) async {
    await _box.put(config.alertType, config);
  }
}
