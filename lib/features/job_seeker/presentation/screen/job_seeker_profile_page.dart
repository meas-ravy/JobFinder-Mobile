import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/switch_role_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/job_seeker/data/model/policy_services.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/jobb_seeker_document.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_settings_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/show_doc.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/shared/widget/danger_tile.dart';
import 'package:job_finder/shared/widget/section_title.dart';
import 'package:job_finder/shared/widget/logout_confirm_dialog.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_provider.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/ai_assistant_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class JobSeekerProfilePage extends HookConsumerWidget {
  const JobSeekerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile;

    useEffect(() {
      Future.microtask(() {
        if (context.mounted) {
          ref.read(profileControllerProvider.notifier).fetchProfile();
        }
      });
      return null;
    }, []);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(l10n.profileTitle),
      ),
      body: SafeArea(
        child: profileState.isLoading && profile == null
            ? _buildShimmerLoading(colorScheme)
            : RefreshIndicator(
                onRefresh: () =>
                    ref.read(profileControllerProvider.notifier).fetchProfile(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  children: [
                    if (profileState.errorMessage != null && profile == null)
                      Center(child: Text(profileState.errorMessage!))
                    else ...[
                      ProfileProgressCard(
                        name: profile?.fullName ?? 'User Name',
                        role: 'Job Seeker',
                        email: profile?.email ?? 'No email provided',
                        imageUrl: profile?.avatarUrl,
                      ),
                      const SizedBox(height: 18),
                    ],

                    // SectionTitle(title: 'Account', textTheme: textTheme),
                    // SettingsTile(
                    //   icon: AppIcon.profile,
                    //   title: 'Personal Information',
                    //   onTap: () {},
                    // ),
                    SettingsTile(
                      icon: AppIcon.switchRole,
                      title: AppLocalizations.of(context).switchToRecruiter,
                      onTap: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => SwitchRoleDialog(
                            avatarUrl: profile?.avatarUrl,
                            targetRole: 'Recruiter',
                            title: l10n.switchRoleTitle,
                            content: l10n.switchRoleContent,
                          ),
                        );

                        if (confirmed != true || !context.mounted) return;

                        LoadingDialog.show(
                          context,
                          message: l10n.switchingToRecruiter,
                        );

                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .selectRole('Recruiter');

                        if (!context.mounted) return;
                        LoadingDialog.hide(context);

                        if (success) {
                          context.go(AppPath.recruiterHome);
                        } else {
                          final error = ref
                              .read(authControllerProvider)
                              .errorMessage;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? l10n.failedToSwitchRole),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                    SettingsTile(
                      icon: AppIcon.documentBold,
                      title: AppLocalizations.of(context).myResume,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyDocumentPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                    SectionTitle(
                      title: AppLocalizations.of(context).generalSection,
                      textTheme: textTheme,
                    ),
                    // SettingsTile(
                    //   icon: AppIcon.notification,
                    //   title: AppLocalizations.of(context).notification,
                    //   onTap: () => context.push(AppPath.notifications),
                    // ),
                    // SettingsTile(
                    //   icon: AppIcon.application,
                    //   title: 'Application Issues',
                    //   onTap: () {},
                    // ),
                    SettingsTile(
                      icon: AppIcon.shieldDone,
                      title: AppLocalizations.of(context).security,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SecuritySettingsScreen(),
                          ),
                        );
                      },
                    ),
                    ValueListenableBuilder<Locale?>(
                      valueListenable: localeController,
                      builder: (context, locale, _) {
                        String langName;
                        switch (locale?.languageCode) {
                          case 'km':
                            langName = l10n.cambodia;
                          case 'ja':
                            langName = l10n.japan;
                          case 'zh':
                            langName = l10n.china;
                          case 'ms':
                            langName = l10n.malaysia;
                          case 'lo':
                            langName = l10n.laos;
                          case 'ko':
                            langName = l10n.korean;
                          default:
                            langName = l10n.englishUS;
                        }
                        return SettingsTile(
                          icon: AppIcon.show,
                          title: l10n.language,
                          trailingText: langName,
                          onTap: () {
                            context.push(AppPath.language);
                          },
                        );
                      },
                    ),

                    // ValueListenableBuilder<ThemeMode>(
                    //   valueListenable: themeModeController,
                    //   builder: (context, mode, _) {
                    //     final isSystem = mode == ThemeMode.system;
                    //     return Column(
                    //       children: [
                    //         SettingsSwitchTile(
                    //           icon: AppIcon.settings,
                    //           title: 'Use device settings',
                    //           value: isSystem,
                    //           onChanged: (value) {
                    //             if (value) {
                    //               themeModeController.setThemeMode(ThemeMode.system);
                    //             } else {
                    //               themeModeController.setThemeMode(ThemeMode.light);
                    //             }
                    //           },
                    //         ),
                    //         SettingsSwitchTile(
                    //           icon: AppIcon.eye,
                    //           title: 'Dark Mode',
                    //           value: mode == ThemeMode.dark,
                    //           onChanged: isSystem
                    //               ? null
                    //               : (value) => themeModeController.setDark(value),
                    //         ),
                    //       ],
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 18),
                    SectionTitle(
                      title: l10n.aboutSection,
                      textTheme: textTheme,
                    ),
                    SettingsTile(
                      icon: AppIcon.infoSqua,
                      title: l10n.privacyPolicy,
                      onTap: () => ShowDoc.showLegalDocument(
                        context,
                        l10n.privacyPolicy,
                        PolicyServices.privacyPolicyContent,
                      ),
                    ),
                    SettingsTile(
                      icon: AppIcon.documentBold,
                      title: l10n.termsOfServices,
                      onTap: () => ShowDoc.showLegalDocument(
                        context,
                        l10n.termsOfServices,
                        PolicyServices.termsOfServiceContent,
                      ),
                    ),

                    SettingsTile(
                      icon: AppIcon.star,
                      title: l10n.aboutUs,
                      onTap: () async {
                        final url = Uri.parse(
                          'https://measravy-site.vercel.app/',
                        );
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.inAppBrowserView,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    DangerTile(
                      icon: AppIcon.logout,
                      title: l10n.logout,
                      onTap: () async {
                        // Show premium confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          barrierDismissible: true,
                          builder: (context) => const LogoutConfirmDialog(),
                        );

                        if (confirmed != true || !context.mounted) return;

                        LoadingDialog.show(context, message: l10n.logout);

                        final success = await ref
                            .read(authControllerProvider.notifier)
                            .logout();

                        if (!context.mounted) return;
                        LoadingDialog.hide(context);

                        if (success) {
                          // Clear token and role, then navigate to login
                          final storage = TokenStorageImpl(
                            const FlutterSecureStorage(),
                          );
                          await storage.delete();
                          await storage.deleteRole();

                          if (!context.mounted) return;
                          context.go(AppPath.sendOtp);
                        } else {
                          final error = ref
                              .read(authControllerProvider)
                              .errorMessage;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Logout failed'),
                              backgroundColor: colorScheme.error,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildShimmerLoading(ColorScheme colorScheme) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Profile Card Shimmer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const ShimmerCircle(radius: 45),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerLoading(width: 150, height: 20),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 100, height: 16),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 180, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: const [
                  SizedBox(width: 16),
                  Expanded(
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 48,
                      borderRadius: 26,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ShimmerLoading(
                      width: double.infinity,
                      height: 48,
                      borderRadius: 26,
                    ),
                  ),
                  SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Sections Shimmer
        for (int i = 0; i < 3; i++) ...[
          const ShimmerLoading(width: 100, height: 18),
          const SizedBox(height: 16),
          for (int j = 0; j < 3; j++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const ShimmerLoading(width: 40, height: 40, borderRadius: 12),
                  const SizedBox(width: 16),
                  const ShimmerLoading(width: 150, height: 16),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ],
    );
  }
}

class ProfileProgressCard extends ConsumerWidget {
  const ProfileProgressCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    this.imageUrl,
  });

  final String name;
  final String role;
  final String email;
  final String? imageUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final healthScore = ref.watch(cvHealthScoreProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: colorScheme.surfaceContainerHighest),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Premium AI Health Score Ring
                  SizedBox(
                    width: 105,
                    height: 105,
                    child: CircularProgressIndicator(
                      value: (healthScore ?? 0) / 100,
                      strokeWidth: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        healthScore == null
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : (healthScore > 70 ? Colors.green : Colors.orange),
                      ),
                    ),
                  ),
                  // Avatar with Shadow
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(imageUrl!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: AppSvgIcon(
                              assetName: AppIcon.profileBold,
                              size: 42,
                              color: colorScheme.primary,
                            ),
                          ),
                  ),
                  if (healthScore != null)
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: (healthScore > 70
                              ? Colors.green
                              : Colors.orange),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$healthScore%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.bolt_rounded,
                          size: 16,
                          color: healthScore == null
                              ? AppColor.primaryDark
                              : (healthScore > 70
                                    ? Colors.green
                                    : Colors.orange),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            healthScore == null
                                ? 'Analyze Match to get Score'
                                : 'Resume Score: ${healthScore > 70 ? "Strong" : "Improving"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: healthScore == null
                                  ? AppColor.primaryDark
                                  : (healthScore > 70
                                        ? const Color.fromARGB(255, 89, 101, 90)
                                        : Colors.orange),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push(AppPath.editProfile),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    AppColor.primaryDark,
                  ),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                  minimumSize: WidgetStateProperty.all(const Size(0, 56)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ],
    );
  }
}
