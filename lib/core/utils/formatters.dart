import 'package:intl/intl.dart';

class AppFormatters {
  const AppFormatters._();

  static final DateFormat date = DateFormat('d MMMM y', 'tr_TR');
  static final DateFormat dateTime = DateFormat('d MMM y HH:mm', 'tr_TR');
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: 'TL',
    decimalDigits: 0,
    customPattern: '#,##0 ¤',
  );
}
