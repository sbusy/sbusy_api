import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');

void log(Object? object) {
  String formatted = formatter.format(DateTime.now());
  print('[$formatted] : $object');
}
