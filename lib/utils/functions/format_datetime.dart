import 'package:intl/intl.dart';

String formatDatetime(DateTime datetime) {
  return DateFormat('EEE, MMM d yyyy').add_jm().format(datetime);
}
