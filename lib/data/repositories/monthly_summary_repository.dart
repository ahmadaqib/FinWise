import 'package:hive_flutter/hive_flutter.dart';
import '../models/monthly_summary.dart';

class MonthlySummaryRepository {
  static const String boxName = 'monthly_summaries';

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<MonthlySummary>(boxName);
    }
  }

  Box<MonthlySummary> get _box => Hive.box<MonthlySummary>(boxName);

  Future<void> saveSummary(MonthlySummary summary) async {
    // Key format: YYYYMM
    final String key =
        '${summary.year}${summary.month.toString().padLeft(2, '0')}';
    await _box.put(key, summary);
  }

  List<MonthlySummary> getAllSummaries() {
    final list = _box.values.toList();
    list.sort((a, b) {
      if (a.year != b.year) return b.year.compareTo(a.year);
      return b.month.compareTo(a.month);
    });
    return list;
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
