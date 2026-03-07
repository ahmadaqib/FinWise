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
}
