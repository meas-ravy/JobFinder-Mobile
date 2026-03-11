import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_finder/core/constants/oauth_config.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/core/helper/theme_mode_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/routes/app_route.dart';
import 'package:job_finder/core/services/agora_service.dart';
import 'package:job_finder/core/constants/agora_config.dart';
import 'package:job_finder/shared/widget/app_lock_wrapper.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/core/theme/app_theme.dart';
import 'package:job_finder/features/job_seeker/data/data_source/object_box.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_finder/firebase_options.dart';
import 'package:job_finder/core/services/notification_service.dart';

late ObjectBox objectBox;

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1️⃣ Initialize Firebase
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      debugPrint('Firebase already initialized, skipping...');
    } else {
      rethrow;
    }
  }

  // 2️⃣ Local storage & services
  objectBox = await ObjectBox.create();
  await GoogleSignIn.instance.initialize(
    serverClientId: OAuthConfig.googleServerClientId,
  );

  final storage = TokenStorageImpl(const FlutterSecureStorage());
  final token = await storage.read();
  final role = await storage.readRole();
  final hasSeenOnboarding = await storage.readHasSeenOnboarding();

  // 3️⃣ Firebase re-auth (VERY IMPORTANT before notifications)
  if (token != null && token.isNotEmpty) {
    try {
      final firebaseToken = await storage.readFirebaseToken();
      if (firebaseToken != null &&
          firebaseToken.isNotEmpty &&
          FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
        debugPrint('Firebase re-auth successful on startup');
      }
    } catch (e) {
      debugPrint('Firebase re-auth failed on startup: $e');
    }
  }

  // 4️⃣ Initialize Notifications + Agora in parallel (AFTER auth)
  await Future.wait([
    NotificationService.instance.initialize(),
    AgoraService.instance.initialize(AgoraConfig.appId),
  ]);

  // 5️⃣ Decide initial route
  String initialRoute = AppPath.splash;

  if (hasSeenOnboarding) {
    if (token == null || token.isEmpty) {
      initialRoute = AppPath.sendOtp;
    } else if (role == null || role.isEmpty) {
      initialRoute = AppPath.selectRole;
    } else {
      initialRoute = role == 'Job_finder'
          ? AppPath.jobSeekerHome
          : AppPath.recruiterHome;
    }
  }

  // 6️⃣ Remove splash only when app is ready
  FlutterNativeSplash.remove();

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

  // Cache font families so they are not re-allocated on every rebuild
  static final _interFont = GoogleFonts.inter().fontFamily;
  static final _battambangFont = GoogleFonts.battambang().fontFamily;
  static final _notoJpFont = GoogleFonts.notoSansJp().fontFamily;
  static final _notoScFont = GoogleFonts.notoSansSc().fontFamily;
  static final _notoLaoFont = GoogleFonts.notoSansLao().fontFamily;
  static final _notoKrFont = GoogleFonts.notoSansKr().fontFamily;

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
    if (locale == null) return _interFont;
    switch (locale.languageCode) {
      case 'km':
        return _battambangFont;
      case 'ja':
        return _notoJpFont;
      case 'zh':
        return _notoScFont;
      case 'lo':
        return _notoLaoFont;
      case 'ko':
        return _notoKrFont;
      default:
        return _interFont;
    }
  }
}
