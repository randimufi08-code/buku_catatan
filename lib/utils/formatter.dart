import 'package:intl/intl.dart';

class Formatter {
  static final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String idr(num value) {
    return _currency.format(value);
  }

  static String dateYmd(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }
}

