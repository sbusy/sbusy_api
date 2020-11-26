import 'package:intl/intl.dart';

final DateFormat _formatter = DateFormat('yyyy-MM-dd hh:mm:ss');

/// Печатает сообщение в формате `[<дата> <время>] : <сообщение>`
void log(Object? object) {
  String formatted = _formatter.format(DateTime.now());
  print('[$formatted] : $object');
}
