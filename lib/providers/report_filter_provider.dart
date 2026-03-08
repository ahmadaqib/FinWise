import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the currently selected month in the Reports screen.
/// Defaults to the current date and time.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
