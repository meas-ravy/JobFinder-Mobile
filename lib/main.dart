import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_theme.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: SendOtpScreen(),
    );
  }
}
