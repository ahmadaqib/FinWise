import 'package:hive/hive.dart';
import '../models/flow_zone.dart';

class FlowZoneRepository {
  static const String _boxName = 'flow_zone_box';
  static const String _key = 'current_flow_zone';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<FlowZone>(_boxName);
    }
  }

  FlowZone getFlowZone() {
    final box = Hive.box<FlowZone>(_boxName);
    return box.get(_key) ?? FlowZone();
  }

  Future<void> saveFlowZone(FlowZone zone) async {
    final box = Hive.box<FlowZone>(_boxName);
    await box.put(_key, zone);
  }
}
