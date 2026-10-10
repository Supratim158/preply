import 'package:flutter/material.dart';

const List<String> kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

const List<String> kWeekdays = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

const List<String> kWeekdayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String formatFullDate(DateTime d) =>
    '${kWeekdays[d.weekday - 1]}, ${d.day} ${kMonths[d.month - 1]} ${d.year}';

String formatTime(BuildContext context, DateTime d) =>
    TimeOfDay.fromDateTime(d).format(context);
