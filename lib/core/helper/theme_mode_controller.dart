import 'package:flutter/material.dart';

class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    if (value == mode) return;
    value = mode;
  }

  void setDark(bool isDark) {
    setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

final ThemeModeController themeModeController = ThemeModeController();
