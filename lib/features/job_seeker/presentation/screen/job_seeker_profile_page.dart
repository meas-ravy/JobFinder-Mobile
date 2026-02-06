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
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_settings_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/show_doc.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/shared/widget/danger_tile.dart';
import 'package:job_finder/shared/widget/section_title.dart';

class JobSeekerProfilePage extends HookConsumerWidget {
  const JobSeekerProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(AppLocalizations.of(context).profileTitle),
      ),
      body: SafeArea(
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            ProfileProgressCard(
              percent: 0.16,
              title: AppLocalizations.of(context).profileCompletedTitle,
              subtitle: AppLocalizations.of(context).profileCompletedSubtitle,
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
              title: AppLocalizations.of(context).myResume,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyDocumentPage()),
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

                LoadingDialog.show(context, message: l10n.switchingToRecruiter);

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
                      content: Text(error ?? l10n.failedToSwitchRole),
                      backgroundColor: Theme.of(context).colorScheme.error,
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
            SectionTitle(title: l10n.aboutSection, textTheme: textTheme),
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
                          backgroundColor: Theme.of(context).colorScheme.error,
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
