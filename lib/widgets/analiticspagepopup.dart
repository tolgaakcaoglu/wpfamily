import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

popUpContainer(BuildContext context, Widget child) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 4.0,
        sigmaY: 4.0,
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colorize.black,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: child,
        ),
      ),
    ),
  );
}

showAnaliticsDatePopUp(context, selectedDate, onDateTimeChanged) =>
    popUpContainer(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: CupertinoDatePicker(
              initialDateTime: selectedDate,
              dateOrder: DatePickerDateOrder.dmy,
              maximumDate: DateTime.now(),
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: onDateTimeChanged,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(8.0),
              color: Colorize.primary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context).filter,
                style: const TextStyle(color: Colorize.black, fontSize: 16.0),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).close.toUpperCase(),
                  style: const TextStyle(color: Colorize.textSec))),
        ],
      ),
    );
