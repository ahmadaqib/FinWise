import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatToIndonesianDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  static int getRemainingDaysInMonth(DateTime date) {
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    return lastDayOfMonth.day - date.day;
  }

  /// Returns [start, end] of the current cycle based on [salaryDate]
  static Map<String, DateTime> getCycleRange(int salaryDate, DateTime now) {
    DateTime start;
    DateTime end;

    if (now.day >= salaryDate) {
      // We are in the current month's cycle
      start = DateTime(now.year, now.month, salaryDate);
      end = DateTime(now.year, now.month + 1, salaryDate - 1, 23, 59, 59);
    } else {
      // We are in the cycle that started last month
      start = DateTime(now.year, now.month - 1, salaryDate);
      end = DateTime(now.year, now.month, salaryDate - 1, 23, 59, 59);
    }

    return {'start': start, 'end': end};
  }

  static int getDaysInCycle(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  static int getRemainingDaysInCycle(DateTime now, DateTime end) {
    return end.difference(now).inDays;
  }
}
