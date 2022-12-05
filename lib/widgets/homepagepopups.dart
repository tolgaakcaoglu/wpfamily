import 'dart:ui';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/carbon.dart';
import 'package:iconify_flutter/icons/eva.dart';
import 'package:iconify_flutter/icons/icon_park_twotone.dart';
import 'package:wpfamilylastseen/const/colors.dart';
import 'package:wpfamilylastseen/funct/functions.dart';
import 'package:wpfamilylastseen/modal/numbersmodal.dart';
import 'package:wpfamilylastseen/widgets/homepagewidgets.dart';
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

standartTitle(String text) => Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(
        fontSize: 22.0, fontWeight: FontWeight.w500, color: Colorize.text));

standartCaption(String text) => Text(text,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 12.0, color: Colorize.textSec));

successPopUp(BuildContext context) => popUpContainer(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          standartTitle(AppLocalizations.of(context).successful),
          const SizedBox(height: 16.0),
          standartCaption(
              AppLocalizations.of(context).successfulAddNumberCaption),
          const SizedBox(height: 24.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(8.0),
              color: Colorize.primary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context).okay,
                style: const TextStyle(color: Colorize.black, fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );

failedPopUp(BuildContext context) => popUpContainer(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          standartTitle(AppLocalizations.of(context).unsuccessful),
          const SizedBox(height: 16.0),
          standartCaption(AppLocalizations.of(context).unsuccessfulCaption),
          const SizedBox(height: 24.0),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: CupertinoButton(
              borderRadius: BorderRadius.circular(8.0),
              color: Colorize.red,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context).okay,
                style: const TextStyle(color: Colorize.black, fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );

editPhonePopUp(BuildContext context, Numbers phone, Function(bool) onChanged,
        bool notification, TextEditingController nameController, device) =>
    popUpContainer(
        context,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            standartTitle(AppLocalizations.of(context).numberSettings),
            const SizedBox(height: 32.0),
            TextFieldy(
              hint: AppLocalizations.of(context).onlineNotification,
              icon: const Iconify(Eva.bell_fill, color: Colorize.icon),
              controller: nameController,
              type: null,
              suffix: Switch(value: notification, onChanged: onChanged),
              enabled: false,
            ),
            const SizedBox(height: 8.0),
            TextFieldy(
              hint: AppLocalizations.of(context).namedNumber,
              icon: const Iconify(IconParkTwotone.edit_name,
                  color: Colorize.icon),
              controller: null,
              type: null,
              suffix: null,
              enabled: true,
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(8.0),
                color: Colorize.primary,
                onPressed: () {
                  Funcs.editNumber(
                      nameController.text.trim(), notification ? 1 : 0, device);

                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context).okay,
                  style: const TextStyle(color: Colorize.black, fontSize: 16.0),
                ),
              ),
            ),
            const Divider(color: Colorize.layer, height: 32.0),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(8.0),
                color: Colorize.layer,
                onPressed: () {
                  Funcs.removeNumber(phone.id, device).then((value) => value == "error"
                      ? failedPopUp(context)
                      : successPopUp(context));

                  Navigator.of(context).pop();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Iconify(Carbon.trash_can,
                        size: 20.0, color: Colorize.red),
                    const SizedBox(width: 8.0),
                    Text(
                      AppLocalizations.of(context).removeNumber,
                      style:
                          const TextStyle(color: Colorize.red, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            standartCaption(AppLocalizations.of(context).removeNumberCaption),
            const SizedBox(height: 8.0),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).close.toUpperCase(),
                    style: const TextStyle(color: Colorize.textSec))),
          ],
        ));

newPhoneAddPopUp(BuildContext context, addingFieldName, addingFieldNumber,
    onPhoneCodePicked, Function onPressed,
    {bool filtered = false,
    bool sortedByIsoCode = false,
    bool hasPriorityList = false,
    bool hasSelectedItemBuilder = false}) {
  double dropdownButtonWidth = 140;
  double dropdownItemWidth = dropdownButtonWidth - 30;
  double dropdownSelectedItemWidth = dropdownButtonWidth - 30;

  return popUpContainer(
    context,
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        standartTitle(AppLocalizations.of(context).addNumber),
        const SizedBox(height: 16.0),
        standartCaption(AppLocalizations.of(context).newPhoneCaption),
        const SizedBox(height: 24.0),
        TextFieldy(
            type: TextInputType.text,
            controller: addingFieldName,
            hint: AppLocalizations.of(context).namedNumber,
            icon:
                const Iconify(IconParkTwotone.edit_name, color: Colorize.icon)),
        const SizedBox(height: 8.0),
        Row(
          children: [
            SizedBox(
              width: dropdownButtonWidth,
              child: CountryPickerDropdown(
                onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                itemHeight: null,
                isDense: false,
                selectedItemBuilder: hasSelectedItemBuilder == true
                    ? (Country country) => _buildDropdownSelectedItemBuilder(
                        country, dropdownSelectedItemWidth)
                    : null,
                itemBuilder: (Country country) => hasSelectedItemBuilder == true
                    ? _buildDropdownItemWithLongText(country, dropdownItemWidth)
                    : _buildDropdownItem(country, dropdownItemWidth),
                initialValue:
                    Localizations.override(context: context).locale.countryCode,
                onValuePicked: onPhoneCodePicked,
              ),
            ),
            Expanded(
                child: TextFieldy(
              type: TextInputType.number,
              controller: addingFieldNumber,
              hint: '533 111 22 33',
            )),
          ],
        ),
        const SizedBox(height: 24.0),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: CupertinoButton(
            borderRadius: BorderRadius.circular(30.0),
            color: Colorize.primary,
            onPressed: onPressed,
            child: Text(
              AppLocalizations.of(context).startTracking,
              style: const TextStyle(color: Colorize.black, fontSize: 16.0),
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          AppLocalizations.of(context).trackingPolicy,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12.0, color: Colorize.icon),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).close.toUpperCase(),
                  style: const TextStyle(color: Colorize.textSec))),
        ),
      ],
    ),
  );
}

Widget _buildDropdownItem(Country country, double dropdownItemWidth) =>
    SizedBox(
      width: dropdownItemWidth,
      child: Row(
        children: <Widget>[
          CountryPickerUtils.getDefaultFlagImage(country),
          const SizedBox(
            width: 8.0,
          ),
          Expanded(child: Text("+${country.phoneCode}(${country.isoCode})")),
        ],
      ),
    );
Widget _buildDropdownSelectedItemBuilder(
        Country country, double dropdownItemWidth) =>
    SizedBox(
        width: dropdownItemWidth,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                CountryPickerUtils.getDefaultFlagImage(country),
                const SizedBox(width: 8.0),
                Expanded(
                    child: Text(
                  country.name,
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                )),
              ],
            )));

Widget _buildDropdownItemWithLongText(
        Country country, double dropdownItemWidth) =>
    SizedBox(
      width: dropdownItemWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(child: Text(country.name)),
          ],
        ),
      ),
    );

showDatePopUp(context, currentDate, onDateTimeChanged) => popUpContainer(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            child: CupertinoDatePicker(
              initialDateTime: currentDate,
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
