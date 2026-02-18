import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
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
import 'package:job_finder/features/job_seeker/presentation/provider/profile_provider.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

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
        ref.read(profileControllerProvider.notifier).fetchProfile();
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
                  physics: const BouncingScrollPhysics(),
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
                        colorScheme: colorScheme,
                        textTheme: textTheme,
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
                    SettingsTile(
                      icon: AppIcon.switchRole,
                      title: AppLocalizations.of(context).switchToRecruiter,
                      onTap: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.switchRoleTitle),
                            content: Text(l10n.switchRoleContent),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  l10n.switchLabel,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
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

                    const SizedBox(height: 18),
                    SectionTitle(
                      title: AppLocalizations.of(context).generalSection,
                      textTheme: textTheme,
                    ),
                    SettingsTile(
                      icon: AppIcon.notification,
                      title: AppLocalizations.of(context).notification,
                      onTap: () {},
                    ),
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
                      onTap: () => ShowDoc.showLegalDocument(
                        context,
                        l10n.aboutUs,
                        PolicyServices.aboutUsContent,
                      ),
                    ),

                    const SizedBox(height: 18),

                    DangerTile(
                      icon: AppIcon.logout,
                      title: l10n.logout,
                      onTap: () async {
                        // Show confirmation dialog
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.logoutConfirmTitle),
                            content: Text(l10n.logoutConfirmContent),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                ),
                                child: Text(
                                  l10n.logout,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed != true || !context.mounted) return;

                        // Clear token and role, then navigate to login
                        final storage = TokenStorageImpl(
                          const FlutterSecureStorage(),
                        );
                        await storage.delete();
                        await storage.deleteRole();

                        if (!context.mounted) return;
                        context.go(AppPath.sendOtp);
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

class ProfileProgressCard extends StatelessWidget {
  const ProfileProgressCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    this.imageUrl,
    required this.colorScheme,
    required this.textTheme,
  });

  final String name;
  final String role;
  final String email;
  final String? imageUrl;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(imageUrl!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: AppSvgIcon(
                              assetName: AppIcon.profileBold,
                              size: 40,
                              color: colorScheme.onSurface,
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 14),
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
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
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
            // Expanded(
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     style: ButtonStyle(
            //       backgroundColor: WidgetStateProperty.all(
            //         AppColor.primaryDark,
            //       ),
            //       overlayColor: WidgetStateProperty.all(Colors.transparent),
            //       elevation: WidgetStateProperty.all(0),
            //       minimumSize: WidgetStateProperty.all(const Size(0, 48)),
            //       shape: WidgetStateProperty.all(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(26),
            //         ),
            //       ),
            //     ),
            //     child: const Text(
            //       'View Profile',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //         fontSize: 15,
            //         color: Colors.white,
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => context.push(AppPath.editProfile),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    AppColor.primaryDark.withValues(alpha: 0.08),
                  ),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  elevation: WidgetStateProperty.all(0),
                  minimumSize: WidgetStateProperty.all(const Size(0, 48)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColor.primaryLight,
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
