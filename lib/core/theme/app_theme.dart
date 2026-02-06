import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(String? fontFamily) => _buildTheme(
    colorScheme: const ColorScheme.light(
      primary: AppColor.primaryLight,
      onPrimary: AppColor.onPrimaryLight,
      secondary: AppColor.secondaryLight,
      onSecondary: AppColor.onSecondaryLight,
      error: AppColor.errorLight,
      onError: AppColor.onErrorLight,
      surface: AppColor.backgroundColorLight,
      onSurface: AppColor.onBackgroundColorLight,
      surfaceContainerHighest: AppColor.surfaceContainerHighestLight,
    ),
    scaffoldBackgroundColor: AppColor.backgroundColorLight,
    bottomNavigationBarColor: AppColor.bottomNavigationBarLight,
    fontFamily: fontFamily,
  );

  static ThemeData dark(String? fontFamily) => _buildTheme(
    colorScheme: const ColorScheme.dark(
      primary: AppColor.primaryDark,
      onPrimary: AppColor.onPrimaryDark,
      secondary: AppColor.secondaryDark,
      onSecondary: AppColor.onSecondaryDark,
      error: AppColor.errorDark,
      onError: AppColor.onErrorDark,
      surface: AppColor.backgroundColorDark,
      onSurface: AppColor.onBackgroundColorDark,
      surfaceContainerHighest: AppColor.surfaceContainerHighestDark,
    ),
    scaffoldBackgroundColor: AppColor.backgroundColorDark,
    bottomNavigationBarColor: AppColor.bottomNavigationBarDark,
    fontFamily: fontFamily,
  );

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color bottomNavigationBarColor,
    String? fontFamily,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      splashColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        //foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      bottomNavigationBarTheme: _bottomNavigationBarTheme(
        backgroundColor: bottomNavigationBarColor,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static BottomNavigationBarThemeData _bottomNavigationBarTheme({
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      enableFeedback: true,
      backgroundColor: backgroundColor,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      selectedLabelStyle: const TextStyle(
        height: 2,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
      unselectedLabelStyle: const TextStyle(
        height: 2,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      ),
    );
  }
}
