import 'package:flutter/widgets.dart';

class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  void setLocale(Locale locale) {
    if (value == locale) return;
    value = locale;
  }

  void clearLocale() {
    value = null;
  }
}

final LocaleController localeController = LocaleController();