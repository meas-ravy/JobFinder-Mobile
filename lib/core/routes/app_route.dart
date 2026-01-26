import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/auth/presentation/screen/app_role_screen.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';
import 'package:job_finder/features/auth/presentation/screen/veriffy_otp.dart';
import 'package:job_finder/features/splash_screen.dart';
import 'package:job_finder/features/wellcome_screen.dart';

class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: '/splash',

    routes: [
      GoRoute(
        path: AppPath.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPath.wellcomescreen,
        builder: (context, state) => const WellcomeScreen(),
      ),
      GoRoute(
        path: AppPath.sendOtp,
        builder: (context, state) => const SendOtpScreen(),
      ),
      // GoRoute(
      //   path: AppPath.verifyOtp,
      //   builder: (context, state) => const VeriffyOtpScreen(phoneNumber: ,),
      // ),
      GoRoute(
        path: AppPath.seleteRole,
        builder: (context, state) => const AppRoleScreen(),
      ),
    ],
  );
}
