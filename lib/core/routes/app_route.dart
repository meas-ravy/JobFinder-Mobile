import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/auth/presentation/screen/app_role_screen.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';
import 'package:job_finder/features/auth/presentation/screen/veriffy_otp.dart';
import 'package:job_finder/features/buton_nav_recruiter.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/create_resume.dart';
import 'package:job_finder/features/main_wrapper.dart';
import 'package:job_finder/features/splash_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/language_screen.dart';
import 'package:job_finder/features/onboarding_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/create_company_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_applied.dart';
import 'package:job_finder/features/recruiter/presentation/screen/edit_company_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_screen.dart';
import 'package:job_finder/features/notifications/presentation/screen/notification_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/setup_edit_profile_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/tip_detail_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/see_all_jobs_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/search_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_detail_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/apply_job_page.dart';

// Global navigator key for accessing navigation from outside widget tree (e.g., 401 interceptor)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  final String initialLocation;
  AppRouter({this.initialLocation = AppPath.splash});

  late final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppPath.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPath.wellcomescreen,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppPath.sendOtp,
        builder: (context, state) => const SendOtpScreen(),
      ),
      GoRoute(
        path: AppPath.verifyOtp,
        builder: (context, state) {
          final phone = state.extra;
          if (phone is String && phone.isNotEmpty) {
            return VeriffyOtpScreen(phoneNumber: phone);
          }
          // If opened directly, fall back to login.
          return const SendOtpScreen();
        },
      ),
      GoRoute(
        path: AppPath.selectRole,
        builder: (context, state) => const AppRoleScreen(),
      ),
      GoRoute(
        path: AppPath.jobSeekerHome,
        builder: (context, state) => const MainWrapper(),
      ),
      GoRoute(
        path: AppPath.recruiterHome,
        builder: (context, state) => const ButonNavRecruiter(),
      ),
      GoRoute(
        path: AppPath.buildTemplate,
        builder: (context, state) => const BuildTemplate(),
      ),
      GoRoute(
        path: AppPath.language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppPath.createCompany,
        builder: (context, state) => const CreateCompanyScreen(),
      ),
      GoRoute(
        path: AppPath.editCompany,
        builder: (context, state) => const EditCompanyScreen(),
      ),
      GoRoute(
        path: AppPath.postJob,
        builder: (context, state) {
          final jobData = state.extra as Map<String, dynamic>?;
          return PostJobScreen(initialJobData: jobData);
        },
      ),
      GoRoute(
        path: AppPath.viewApplicants,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return RecruiterAppliedPage(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppPath.notifications,
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: AppPath.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppPath.setupProfile,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditProfilePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic)),
              ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: AppPath.tipDetail,
        builder: (context, state) {
          final tipId = state.extra as String?;
          return TipDetailScreen(tipId: tipId ?? '');
        },
      ),
      GoRoute(
        path: AppPath.seeAllRecommended,
        builder: (context, state) =>
            const SeeAllJobsPage(type: SeeAllType.recommended),
      ),
      GoRoute(
        path: AppPath.seeAllRecent,
        builder: (context, state) =>
            const SeeAllJobsPage(type: SeeAllType.recent),
      ),
      GoRoute(
        path: AppPath.search,
        builder: (context, state) => const SearchPage(),
      ),
      GoRoute(
        path: AppPath.jobDetail,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return JobDetailPage(jobId: jobId ?? '');
        },
      ),
      GoRoute(
        path: AppPath.applyJob,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return ApplyJobPage(jobId: jobId ?? '');
        },
      ),
    ],
  );
}
