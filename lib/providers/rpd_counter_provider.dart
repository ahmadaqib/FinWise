import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';

const String _rpdBoxName = 'rpd_counter';

/// Tracks daily API request count to enforce RPD limits.
class RpdCounter {
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_rpdBoxName)) {
      await Hive.openBox<int>(_rpdBoxName);
    }
  }

  static Box<int> get _box => Hive.box<int>(_rpdBoxName);

  static String get _todayKey {
    final now = DateTime.now();
    return 'rpd_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int get usedToday => _box.get(_todayKey, defaultValue: 0)!;
  static int get remainingToday => AppConstants.maxRpdPerDay - usedToday;
  static bool get canMakeRequest => remainingToday > 0;

  static Future<void> increment() async {
    await _box.put(_todayKey, usedToday + 1);
  }

  /// Clean up old date keys (keep only today)
  static Future<void> cleanup() async {
    final today = _todayKey;
    final keysToDelete = _box.keys.where((k) => k != today).toList();
    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }
}

/// Provider exposing remaining RPD count
final rpdRemainingProvider = Provider<int>((ref) {
  return RpdCounter.remainingToday;
});
