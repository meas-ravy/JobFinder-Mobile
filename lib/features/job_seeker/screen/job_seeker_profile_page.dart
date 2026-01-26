import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/core/helper/theme_mode_controller.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class JobSeekerProfilePage extends StatefulWidget {
  const JobSeekerProfilePage({super.key});

  @override
  State<JobSeekerProfilePage> createState() => _JobSeekerProfilePageState();
}

class _JobSeekerProfilePageState extends State<JobSeekerProfilePage> {
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
            _ProfileProgressCard(
              percent: 0.95,
              title: 'Profile Completed!',
              subtitle:
                  'A complete profile increases the chances\nof a recruiter being more interested in\nrecruiting you',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 18),

            _SectionTitle(title: 'Account', textTheme: textTheme),
            _SettingsTile(
              icon: AppIcon.profile,
              title: 'Personal Information',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.switchRole,
              title: 'Linked Accounts',
              onTap: () {},
            ),

            const SizedBox(height: 18),
            _SectionTitle(title: 'General', textTheme: textTheme),
            _SettingsTile(
              icon: AppIcon.notification,
              title: 'Notification',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.application,
              title: 'Application Issues',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.timeSquare,
              title: 'Timezone',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.shieldDone,
              title: 'Security',
              onTap: () {},
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
            _SettingsTile(
              icon: AppIcon.infoSqua,
              title: 'Privacy & Policy',
              onTap: () {},
            ),
            _SettingsTile(
              icon: AppIcon.document,
              title: 'Terms of Services',
              onTap: () {},
            ),
            _SettingsTile(icon: AppIcon.star, title: 'About us', onTap: () {}),

            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),

            _DangerTile(
              icon: Icons.no_accounts_outlined,
              title: 'Deactivate My Account',
              onTap: () {},
            ),
            _DangerTile(icon: Icons.logout, title: 'Logout', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard({
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
        activeColor: AppColor.primaryLight,
      ),
    );
  }
}

class _DangerTile extends StatelessWidget {
  const _DangerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final danger = colorScheme.error;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: danger),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: danger,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: danger.withValues(alpha: 0.7)),
      onTap: onTap,
    );
  }
}
