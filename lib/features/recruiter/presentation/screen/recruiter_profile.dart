import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/locale_controller.dart';
import 'package:job_finder/core/helper/secure_storage.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/auth/presentation/provider/auth_provider.dart';
import 'package:job_finder/features/job_seeker/data/model/policy_services.dart';
import 'package:job_finder/features/job_seeker/presentation/screen/security_settings_screen.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/dialogs/show_doc.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/widget/danger_tile.dart';
import 'package:job_finder/shared/widget/loading_dialog.dart';
import 'package:job_finder/shared/widget/section_title.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';

class RecruiterProfilePage extends HookConsumerWidget {
  const RecruiterProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final recruiterState = ref.watch(recruiterControllerProvider);
    final company = recruiterState.company;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const _HeaderSection(),
      ),
      body: SafeArea(
        child: recruiterState.isLoading
            ? const _ProfileShimmer()
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _ProfileProgressCard(
                    company: company,
                    percent: 0.95,
                    title: company != null
                        ? 'Profile Completed!'
                        : 'Complete Your Profile',
                    subtitle: company != null
                        ? 'A complete profile increases the chances\nof a recruiter being more interested in\nrecruiting you'
                        : 'Establish your company presence to start posting jobs and finding candidates.',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 18),

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
                        final error = ref
                            .read(authControllerProvider)
                            .errorMessage;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Failed to switch role'),
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
                  //         _SettingsSwitchTile(
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
                  //         _SettingsSwitchTile(
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
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              child: const Text('Logout'),
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
    );
  }
}

class _ProfileProgressCard extends StatelessWidget {
  const _ProfileProgressCard({
    required this.company,
    required this.percent,
    required this.title,
    required this.subtitle,
    required this.colorScheme,
    required this.textTheme,
  });

  final CompanyModel? company;
  final double percent;
  final String title;
  final String subtitle;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    // Use actual company info if available, otherwise use defaults/placeholders
    final name = company?.name ?? 'Complete Company Profile';
    final email = company?.contactEmail ?? 'No email set';

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    backgroundImage:
                        (company?.logoUrl != null &&
                            company!.logoUrl.isNotEmpty)
                        ? NetworkImage(company!.logoUrl)
                        : null,
                    child:
                        (company?.logoUrl == null || company!.logoUrl.isEmpty)
                        ? Text(
                            company?.name.characters.firstOrNull
                                    ?.toUpperCase() ??
                                'C',
                            style: textTheme.headlineMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (company?.isVerified == true)
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Verified',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: 0, // TODO: Add jobs posted count to model if needed
                    label: 'Jobs posted',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  _VerticalDottedLine(colorScheme: colorScheme),
                  _StatItem(
                    value: 0, // TODO: Add applied count to model if needed
                    label: 'Applied',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                  _VerticalDottedLine(colorScheme: colorScheme),
                  _StatItem(
                    value: company?.followerCount ?? 0,
                    label: (company?.followerCount ?? 0) > 1
                        ? 'Followers'
                        : 'Follower',
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Job Hire rate',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 1,
                      height: 16,
                      color: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(width: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: company?.hireRating ?? 0.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.easeOutCubic,
                      builder: (context, val, child) {
                        return Text(
                          '${val.toStringAsFixed(1)}%',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: () {
                if (company == null) {
                  context.push(AppPath.createCompany);
                } else {
                  context.push(AppPath.editCompany);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                company == null ? 'Set Up Profile' : 'Edit Bio',
                style: textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  final int value;
  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Text(
              val.toInt().toString(),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VerticalDottedLine extends StatelessWidget {
  const _VerticalDottedLine({required this.colorScheme});
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: DottedLine(
        direction: Axis.vertical,
        dashColor: colorScheme.outlineVariant.withValues(alpha: 0.2),
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
    // ignore: unused_element_parameter
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

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(
          'Profile',
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.onSurface.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(10),
          child: AppSvgIcon(
            assetName: AppIcon.notification,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // Card Shimmer
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const ShimmerCircle(radius: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerLoading(width: 150, height: 20),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 100, height: 16),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 80, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Column(
                    children: [
                      ShimmerLoading(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLoading(width: 60, height: 12),
                    ],
                  ),
                  Column(
                    children: [
                      ShimmerLoading(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLoading(width: 60, height: 12),
                    ],
                  ),
                  Column(
                    children: [
                      ShimmerLoading(width: 40, height: 20),
                      SizedBox(height: 4),
                      ShimmerLoading(width: 60, height: 12),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: const [
            Expanded(
              child: ShimmerLoading(
                width: double.infinity,
                height: 48,
                borderRadius: 24,
              ),
            ),
            SizedBox(width: 16),
            ShimmerLoading(width: 100, height: 48, borderRadius: 24),
          ],
        ),
        const SizedBox(height: 32),
        // Settings items shimmers
        for (int i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                ShimmerCircle(radius: 12),
                SizedBox(width: 16),
                ShimmerLoading(width: 120, height: 16),
                Spacer(),
                ShimmerLoading(width: 20, height: 20),
              ],
            ),
          ),
      ],
    );
  }
}
