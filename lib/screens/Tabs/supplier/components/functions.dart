import 'package:intl/intl.dart';

String formatDate(String inputDate) {
  // Convert input string to DateTime object
  DateTime date = DateTime.parse(inputDate);

  // Format the DateTime object to the desired format
  DateFormat formatter = DateFormat('dd MMM yyyy');
  String formattedDate = formatter.format(date);

  return formattedDate;
}