import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/auth/presentation/screen/app_role_screen.dart';
import 'package:job_finder/features/auth/presentation/screen/send_otp.dart';
import 'package:job_finder/features/auth/presentation/screen/veriffy_otp.dart';
import 'package:job_finder/features/buton_nav_recruiter.dart';
import 'package:job_finder/features/chat/presentation/screen/incoming_call_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/create_resume.dart';
import 'package:job_finder/features/main_wrapper.dart';
import 'package:job_finder/features/splash_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/language_screen.dart';
import 'package:job_finder/features/onboarding_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/create_company_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_applied.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_application_detail.dart';
import 'package:job_finder/features/recruiter/presentation/screen/edit_company_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/post_job_screen.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_chat_detail.dart';
import 'package:job_finder/features/notifications/presentation/screen/notification_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/setup_edit_profile_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/tip_detail_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/see_all_jobs_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/search_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_detail_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/apply_job_page.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/message_detail_screen.dart';
import 'package:job_finder/features/chat/presentation/screen/call_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/job_seeker_application_detail.dart';

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
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialIndex = int.tryParse(tabStr ?? '');
          return MainWrapper(initialIndex: initialIndex);
        },
      ),
      GoRoute(
        path: AppPath.recruiterHome,
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialIndex = int.tryParse(tabStr ?? '');
          return ButonNavRecruiter(initialIndex: initialIndex);
        },
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
          final extra = state.extra;
          final jobData = (extra is Map)
              ? Map<String, dynamic>.from(extra)
              : null;
          return PostJobScreen(initialJobData: jobData);
        },
      ),
      GoRoute(
        path: AppPath.viewApplicants,
        builder: (context, state) {
          final jobId = state.extra as String?;
          return RecruiterAppliedPage(jobId: jobId);
        },
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final jobId = state.pathParameters['id'];
              return RecruiterAppliedPage(jobId: jobId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '${AppPath.applicationDetail}/:id',
        builder: (context, state) {
          final applicationId = state.pathParameters['id'];
          return RecruiterApplicationDetailPage(id: applicationId ?? '');
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
        path: '${AppPath.tipDetail}/:id',
        builder: (context, state) {
          final tipId = state.pathParameters['id'];
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
        path: '${AppPath.jobDetail}/:id',
        builder: (context, state) {
          final jobId = state.pathParameters['id'];
          return JobDetailPage(jobId: jobId ?? '');
        },
      ),
      GoRoute(
        path: '${AppPath.applyJob}/:id',
        builder: (context, state) {
          final jobId = state.pathParameters['id'];
          return ApplyJobPage(jobId: jobId ?? '');
        },
      ),
      GoRoute(
        path: '${AppPath.chatDetail}/:id',
        builder: (context, state) {
          final conversationId = state.pathParameters['id'] ?? '';
          final extraData = state.extra;
          final extra = (extraData is Map) ? DataMap.from(extraData) : null;
          return RecruiterChatDetailScreen(
            conversationId: conversationId,
            candidateName: extra?['candidateName'] ?? 'Chat',
            candidateAvatar: extra?['candidateAvatar'],
          );
        },
      ),
      GoRoute(
        path: '${AppPath.jobSeekerChatDetail}/:id',
        builder: (context, state) {
          final conversationId = state.pathParameters['id'] ?? '';
          final extraData = state.extra;
          final extra = (extraData is Map) ? DataMap.from(extraData) : null;
          return JobSeekerChatDetailScreen(
            conversationId: conversationId,
            name: extra?['name'] ?? 'Chat',
            avatar: extra?['avatar'],
          );
        },
      ),
      GoRoute(
        path: '${AppPath.jobSeekerApplicationDetail}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return JobSeekerApplicationDetailPage(id: id ?? '');
        },
      ),
      GoRoute(
        path: AppPath.call,
        builder: (context, state) {
          final extraData = state.extra;
          final extra = (extraData is Map) ? DataMap.from(extraData) : null;
          final queryParams = state.uri.queryParameters;

          final channelName =
              extra?['channelName'] ?? queryParams['channelName'] ?? '';
          if (channelName.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Invalid call: Missing channel name")),
            );
          }

          return CallScreen(
            channelName: channelName,
            token: extra?['token'] ?? queryParams['token'],
            appId: extra?['appId'] ?? queryParams['appId'],
            uid: extra?['uid'] ?? queryParams['uid'],
            isVideoCall:
                (extra?['isVideoCall'] ??
                    (queryParams['isVideoCall'] == 'true')) ??
                false,
            remoteName:
                extra?['remoteName'] ?? queryParams['remoteName'] ?? 'Unknown',
            remoteAvatar: extra?['remoteAvatar'] ?? queryParams['remoteAvatar'],
          );
        },
      ),
      GoRoute(
        path: AppPath.incomingCall,
        builder: (context, state) {
          final extraData = state.extra;
          final extra = (extraData is Map) ? DataMap.from(extraData) : null;
          final queryParams = state.uri.queryParameters;

          final channelName =
              extra?['channelName'] ?? queryParams['channelName'] ?? '';
          if (channelName.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("Invalid call: Missing channel name")),
            );
          }

          return IncomingCallScreen(
            channelName: channelName,
            isVideoCall:
                (extra?['isVideoCall'] ??
                    (queryParams['isVideoCall'] == 'true')) ??
                false,
            remoteName:
                extra?['remoteName'] ?? queryParams['remoteName'] ?? 'Unknown',
            remoteAvatar: extra?['remoteAvatar'] ?? queryParams['remoteAvatar'],
          );
        },
      ),
    ],
  );
}
