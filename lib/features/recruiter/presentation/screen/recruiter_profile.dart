import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/helper/theme_mode_controller.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/job_seeker/data/model/policy_services.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_settings_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/show_doc.dart';
import 'package:job_finder/shared/widget/danger_tile.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/shared/widget/section_title.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class RecruiterProfilePage extends ConsumerStatefulWidget {
  const RecruiterProfilePage({super.key});

  @override
  ConsumerState<RecruiterProfilePage> createState() =>
      _RecruiterProfilePageState();
}

class _RecruiterProfilePageState extends ConsumerState<RecruiterProfilePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // _ProfileProgressCard(
            //   percent: 0.95,
            //   title: 'Profile Completed!',
            //   subtitle:
            //       'A complete profile increases the chances\nof a recruiter being more interested in\nrecruiting you',
            //   colorScheme: colorScheme,
            //   textTheme: textTheme,
            // ),
            const SizedBox(height: 18),

            _SectionTitle(title: 'Account', textTheme: textTheme),
            _SettingsTile(
              icon: AppIcon.profile,
              title: 'Personal Information',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.switchRole,
              title: 'Switch to Job Finder',
              onTap: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Switch Role'),
                    content: const Text(
                      'Switch to Job Finder mode? You can switch back anytime.',
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
                  message: 'Switching to Job Finder...',
                );

                // Call select-role API
                final success = await ref
                    .read(authControllerProvider.notifier)
                    .selectRole('Job_finder');

                if (!context.mounted) return;
                LoadingDialog.hide(context);

                if (success) {
                  // Navigate to Job Seeker home
                  context.go(AppPath.jobSeekerHome);
                } else {
                  // Show error
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
            _SectionTitle(title: 'General', textTheme: textTheme),
            _SettingsTile(
              icon: AppIcon.notification,
              title: 'Notification',
              onTap: () {},
            ),
            // _SettingsTile(
            //   icon: AppIcon.timeSquare,
            //   title: 'Timezone',
            //   onTap: () {},
            // ),
            _SettingsTile(
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
            _SettingsTile(
              icon: AppIcon.show,
              title: 'Language',
              trailingText: 'English (US)',
              onTap: () {},
            ),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeModeController,
              builder: (context, mode, _) {
                final isSystem = mode == ThemeMode.system;
                return Column(
                  children: [
                    _SettingsSwitchTile(
                      icon: AppIcon.settings,
                      title: 'Use device settings',
                      value: isSystem,
                      onChanged: (value) {
                        if (value) {
                          themeModeController.setThemeMode(ThemeMode.system);
                        } else {
                          themeModeController.setThemeMode(ThemeMode.light);
                        }
                      },
                    ),
                    _SettingsSwitchTile(
                      icon: AppIcon.eye,
                      title: 'Dark Mode',
                      value: mode == ThemeMode.dark,
                      onChanged: isSystem
                          ? null
                          : (value) => themeModeController.setDark(value),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            _SectionTitle(title: 'About', textTheme: textTheme),
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
                        child: const Text('Logout'),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.textTheme});
  final String title;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: AppSvgIcon(
        assetName: icon,
        size: 24,
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                trailingText!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurface.withValues(alpha: 0.35),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: AppSvgIcon(
        assetName: icon,
        size: 24,
        color: colorScheme.onSurface.withValues(alpha: 0.75),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        // ignore: deprecated_member_use
        activeColor: AppColor.primaryLight,
      ),
    );
  }
}
