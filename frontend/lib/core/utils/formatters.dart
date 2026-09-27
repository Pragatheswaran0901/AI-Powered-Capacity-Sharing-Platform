import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  static String currency(num? amount) {
    if (amount == null) return '₹0';
    return _currencyFormat.format(amount);
  }

  static String date(DateTime? dt) {
    if (dt == null) return '-';
    return _dateFormat.format(dt);
  }

  static String dateTime(DateTime? dt) {
    if (dt == null) return '-';
    return _dateTimeFormat.format(dt);
  }

  static String distance(double? km) {
    if (km == null) return '-';
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}
