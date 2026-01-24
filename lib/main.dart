import 'package:flutter/material.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/core/theme/app_theme.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SendOtpScreen(),
        );
      },
    );
  }
}
