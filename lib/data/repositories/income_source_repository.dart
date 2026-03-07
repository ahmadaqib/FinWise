import 'package:hive_flutter/hive_flutter.dart';
import '../models/income_source.dart';

class IncomeSourceRepository {
  static const String boxName = 'income_sources';

  Box<IncomeSource> get _box => Hive.box<IncomeSource>(boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<IncomeSource>(boxName);
    }
  }

  List<IncomeSource> getAllIncomeSources() {
    return _box.values.toList();
  }

  List<IncomeSource> getActiveIncomeSources() {
    return _box.values.where((source) => source.isActive).toList();
  }

  Future<void> addIncomeSource(IncomeSource source) async {
    await _box.put(source.id, source);
  }

  Future<void> updateIncomeSource(IncomeSource source) async {
    await source.save();
  }

  Future<void> deleteIncomeSource(String id) async {
    await _box.delete(id);
  }
}
