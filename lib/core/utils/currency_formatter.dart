import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(amount);
  }
}
