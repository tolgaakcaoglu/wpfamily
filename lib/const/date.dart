import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

List<String> months = [
  'january',
  'february',
  'march',
  'april',
  'may',
  'june',
  'july',
  'august',
  'september',
  'october',
  'november',
  'december'
];

String getMonth(BuildContext context, int month) {
  String dayOfWeek =
      DateFormat.MMMM(Localizations.localeOf(context).languageCode)
          .format(DateTime.utc(DateTime.now().year, month));

  return dayOfWeek;
}
