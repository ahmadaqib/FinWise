import 'package:hive/hive.dart';
import '../models/emergency_fund.dart';

class EmergencyFundRepository {
  static const String boxName = 'emergency_fund';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<EmergencyFundEntry>(boxName);
    }
  }

  Box<EmergencyFundEntry> get _box => Hive.box<EmergencyFundEntry>(boxName);

  List<EmergencyFundEntry> getAll() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double getTotalBalance() {
    return _box.values.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  Future<void> addEntry(EmergencyFundEntry entry) async {
    await _box.put(entry.id, entry);
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
