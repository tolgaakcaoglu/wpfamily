import 'package:flutter/cupertino.dart';
import 'package:wpfamilylastseen/l10n/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale;
  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;

    _locale = locale;
    notifyListeners();
  }

  void clearLocale(Locale locale) {
    _locale = null;
    notifyListeners();
  }
}
