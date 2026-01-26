import 'package:flutter/material.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';

/// Global navigation helpers for code that doesn't have a `BuildContext`
/// (e.g. Dio interceptors).
class AppNavigator {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static void goToSendOtpAndClearStack() {
    final navigator = key.currentState;
    if (navigator == null) return;
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SendOtpScreen()),
      (route) => false,
    );
  }
}
