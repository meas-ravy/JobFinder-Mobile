import 'package:flutter/material.dart';

@immutable
abstract class AppColor {
  const AppColor();

  static const Color findEmp = Color(0xffFEA01D);
  static const Color findJob = Color(0xff246BFD);
  static const Color snackBarSuccess = Color(0xff01E47A);
  static const Color snackBarFailed = Color(0xffFE5151);
  static const Color transparent = Colors.transparent;

  /// light
  static const Color backgroundColorLight = Color(0xffffffff);
  static const Color onBackgroundColorLight = Color(0xff121212);
  static const Color bottomNavigationBarLight = Color(0xffffffff);
  static const Color primaryLight = Color(0xff246BFD);
  static const Color onPrimaryLight = Color(0xfffefefe);
  static const Color secondaryLight = Color(0xff8768DD);
  static const Color onSecondaryLight = Color(0xff8596A0);
  static const Color borderLight = Color(0xff5F44B9);
  static const Color errorLight = Colors.redAccent;
  static const Color onErrorLight = Color(0xffffffff);
  static const Color surfaceLight = Color(0xff7050d9);
  static const Color onSurfaceLight = Color(0xffffffff);
  static const Color surfaceContainerHighestLight = Color(0xfff5f4f4);
  static const Color bottomNavigationBarDividerColorLight = Color(0xffeeeeee);
  static const Color chatPageSystemNavigationBarColorLight = Color(0xff5F44B9);
  static const Color rightMessageColorLight = Color(0xffcecbff);
  static const Color leftMessageColorLight = Color(0xffffffff);
  static const Color rightMessageTextColorLight = Color(0xff222222);
  static const Color leftMessageTextColorLight = Color(0xff222222);
  static const Color cardLight = Color(0xFF161E34);
  static const Color cardBorderLight = Color(0xFF253054);
  static const Color textMutedLight = Color(0xFF8A94A8);
  static const Color appliedLight = Color(0xFF22D38A);
  static const Color interviewLight = Color(0xFFF1C65A);
  static const Color confirmLight = Color(0xFF8B5CF6);

  /// dark
  static const Color backgroundColorDark = Color(0xff121212);
  static const Color onBackgroundColorDark = Color(0xffffffff);
  static const Color bottomNavigationBarDark = Color(0xff121212);
  static const Color primaryDark = Color(0xff246BFD);
  static const Color onPrimaryDark = Color(0xffaaa1c2);
  static const Color secondaryDark = Color(0xff774efa);
  static const Color onSecondaryDark = Color(0xffBBB7C6);
  static const Color borderDark = Color(0xff5F44B9);
  static const Color errorDark = Colors.redAccent;
  static const Color onErrorDark = Color(0xffffffff);
  static const Color surfaceDark = Color(0xff7050d9);
  static const Color onSurfaceDark = Color(0xffBBB7C6);
  static const Color surfaceContainerHighestDark = Color(0xff1e222a);
  static const Color bottomNavigationBarDividerColorDark = Color(0xff222222);
  static const Color chatPageSystemNavigationBarColorDark = Color(0xFF2F2653);
  static const Color rightMessageColorDark = Color(0xff5F44B9);
  static const Color leftMessageColorDark = Color(0xff443463);
  static const Color rightMessageTextColorDark = Color(0xffeeeeee);
  static const Color leftMessageTextColorDark = Color(0xffeeeeee);
  static const Color cardDark = Color(0xFF161E34);
  static const Color cardBorderDark = Color(0xFF253054);
  static const Color textMutedDark = Color(0xFF8A94A8);
  static const Color appliedDark = Color(0xFF22D38A);
  static const Color interviewDark = Color(0xFFF1C65A);
  static const Color confirmDark = Color(0xFF8B5CF6);
}
