import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/job_seeker/data/model/policy_services.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/jobb_seeker_document.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/language_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_settings_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/show_doc.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/shared/widget/danger_tile.dart';
import 'package:job_finder/shared/widget/section_title.dart';

class JobSeekerProfilePage extends HookConsumerWidget {
  const JobSeekerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ProfileProgressCard(
              percent: 0.16,
              title: 'Profile Completed!',
              subtitle:
                  'A complete profile increases the chances\nof a recruiter being more interested in\nrecruiting you',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 18),

            // SectionTitle(title: 'Account', textTheme: textTheme),
            // SettingsTile(
            //   icon: AppIcon.profile,
            //   title: 'Personal Information',
            //   onTap: () {},
            // ),
            SettingsTile(
              icon: AppIcon.documentBold,
              title: 'My Documents',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyDocumentPage()),
                );
              },
            ),
            SettingsTile(
              icon: AppIcon.switchRole,
              title: 'Switch to Recruiter',
              onTap: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Switch Role'),
                    content: const Text(
                      'Switch to Recruiter mode? You can switch back anytime.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Switch',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed != true || !context.mounted) return;

                LoadingDialog.show(
                  context,
                  message: 'Switching to Recruiter...',
                );

                final success = await ref
                    .read(authControllerProvider.notifier)
                    .selectRole('Recruiter');

                if (!context.mounted) return;
                LoadingDialog.hide(context);

                if (success) {
                  context.go(AppPath.recruiterHome);
                } else {
                  final error = ref.read(authControllerProvider).errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Failed to switch role'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 18),
            SectionTitle(title: 'General', textTheme: textTheme),
            SettingsTile(
              icon: AppIcon.notification,
              title: 'Notification',
              onTap: () {},
            ),
            // SettingsTile(
            //   icon: AppIcon.application,
            //   title: 'Application Issues',
            //   onTap: () {},
            // ),
            SettingsTile(
              icon: AppIcon.shieldDone,
              title: 'Security',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SecuritySettingsScreen(),
                  ),
                );
              },
            ),
            SettingsTile(
              icon: AppIcon.show,
              title: 'Language',
              trailingText: 'English (US)',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguageScreen()),
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
            SectionTitle(title: 'About', textTheme: textTheme),
            SettingsTile(
              icon: AppIcon.infoSqua,
              title: 'Privacy & Policy',
              onTap: () => ShowDoc.showLegalDocument(
                context,
                'Privacy Policy',
                PolicyServices.privacyPolicyContent,
              ),
            ),
            SettingsTile(
              icon: AppIcon.documentBold,
              title: 'Terms of Services',
              onTap: () => ShowDoc.showLegalDocument(
                context,
                'Terms of Services',
                PolicyServices.termsOfServiceContent,
              ),
            ),
            SettingsTile(
              icon: AppIcon.star,
              title: 'About us',
              onTap: () => ShowDoc.showLegalDocument(
                context,
                'About Us',
                PolicyServices.aboutUsContent,
              ),
            ),

            const SizedBox(height: 18),

            DangerTile(
              icon: AppIcon.logout,
              title: 'Logout',
              onTap: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed != true || !context.mounted) return;

                // Clear token and role, then navigate to login
                final storage = TokenStorageImpl(const FlutterSecureStorage());
                await storage.delete();
                await storage.deleteRole();

                if (!context.mounted) return;
                context.go(AppPath.sendOtp);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileProgressCard extends StatelessWidget {
  const ProfileProgressCard({
    super.key,
    required this.percent,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
  });

  final double percent;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColor.primaryLight,
        AppColor.primaryLight.withValues(alpha: 0.82),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            width: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '${(percent * 100).round()}%',
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
