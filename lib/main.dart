import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_finder/core/constants/oauth_config.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/core/helper/theme_mode_controller.dart';
import 'package:job_finder/core/routes/app_route.dart';
import 'package:job_finder/shared/widget/app_lock_wrapper.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/core/theme/app_theme.dart';
import 'package:job_finder/features/job_seeker/data/data_source/object_box.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

late ObjectBox objectBox;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  await GoogleSignIn.instance.initialize(
    serverClientId: OAuthConfig.googleServerClientId,
  );
  runApp(
    ProviderScope(
      overrides: [objectBoxProvider.overrideWithValue(objectBox)],
      child: const MyApp(),
    ),
  );
}

final objectBoxProvider = Provider<ObjectBox>((ref) {
  throw UnimplementedError();
});

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeController,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeController,
          builder: (context, locale, _) {
            final String? fontFamily = _getFontFamily(locale);

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              locale: locale,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appName,
              theme: AppTheme.light(fontFamily),
              darkTheme: AppTheme.dark(fontFamily),
              themeMode: themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: AppRouter().router,
              builder: (context, child) {
                return AppLockWrapper(child: child!);
              },
            );
          },
        );
      },
    );
  }

  String? _getFontFamily(Locale? locale) {
    if (locale == null) return GoogleFonts.inter().fontFamily;
    switch (locale.languageCode) {
      case 'km':
        return GoogleFonts.battambang().fontFamily;
      case 'ja':
        return GoogleFonts.notoSansJp().fontFamily;
      case 'zh':
        return GoogleFonts.notoSansSc().fontFamily;
      case 'lo':
        return GoogleFonts.notoSansLao().fontFamily;
      case 'ko':
        return GoogleFonts.notoSansKr().fontFamily;
      default:
        return GoogleFonts.inter().fontFamily;
    }
  }
}
