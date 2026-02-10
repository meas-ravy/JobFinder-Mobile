import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_finder/core/constants/oauth_config.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/core/helper/theme_mode_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
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

  // Logic to determine initial route
  final storage = TokenStorageImpl(const FlutterSecureStorage());
  final token = await storage.read();
  final role = await storage.readRole();
  final hasSeenOnboarding = await storage.readHasSeenOnboarding();

  String initialRoute = AppPath.splash; // Default (animations)

  if (hasSeenOnboarding) {
    if (token == null || token.isEmpty) {
      initialRoute = AppPath.sendOtp; // Go straight to Login
    } else if (role == null || role.isEmpty) {
      initialRoute = AppPath.selectRole;
    } else {
      initialRoute = role == 'Job_finder'
          ? AppPath.jobSeekerHome
          : AppPath.recruiterHome;
    }
  }

  runApp(
    ProviderScope(
      overrides: [objectBoxProvider.overrideWithValue(objectBox)],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

final objectBoxProvider = Provider<ObjectBox>((ref) {
  throw UnimplementedError();
});

class MyApp extends StatefulWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(initialLocation: widget.initialRoute);
  }

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
              routerConfig: _appRouter.router,
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
