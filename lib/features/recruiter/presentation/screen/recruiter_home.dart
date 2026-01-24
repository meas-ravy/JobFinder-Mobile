import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class RecruiterHomePage extends StatelessWidget {
  const RecruiterHomePage({super.key});

  static const List<JobCardData> _jobs = [
    JobCardData(
      title: 'UI Designer',
      company: 'Netflix',
      date: '1 Jan 2023',
      description:
          'We are looking for a dynamic UI/UX designer who will be responsible...',
    ),
    JobCardData(
      title: 'Content Writer',
      company: 'VK',
      date: '4 Jan 2023',
      description:
          'We are looking for a dynamic writer who will be responsible...',
    ),
    JobCardData(
      title: 'UI Designer',
      company: 'Slack',
      date: '6 Jan 2023',
      description:
          'We are looking for a dynamic UI/UX designer who will be responsible...',
    ),
    JobCardData(
      title: 'Python Developer',
      company: 'Python',
      date: '4 Jan 2023',
      description:
          'We are looking for a dynamic developer who will be responsible...',
    ),
    JobCardData(
      title: 'UI Designer',
      company: 'Pinterest',
      date: '1 Jan 2023',
      description:
          'We are looking for a dynamic UI/UX designer who will be responsible...',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = scheme.surfaceContainerHighest;
    final cardBorder = scheme.outlineVariant.withValues(
      alpha: isDark ? 0.5 : 0.7,
    );
    final textPrimary = scheme.onSurface;
    final textMuted = scheme.onSurface.withValues(alpha: isDark ? 0.6 : 0.7);
    final accentColors = [
      scheme.primary,
      scheme.secondary,
      scheme.primary,
      scheme.secondary,
      scheme.primary,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: false,
            backgroundColor: scheme.surface,
            surfaceTintColor: scheme.surface,
            elevation: 0,
            toolbarHeight: 84,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: _HeaderSection(
                textPrimary: textPrimary,
                textMuted: textMuted,
                accent: scheme.primary,
                onAccent: scheme.onPrimary,
                cardColor: cardColor,
                cardBorder: cardBorder,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) {
                  return const SizedBox(height: 12);
                }
                final itemIndex = index ~/ 2;
                final item = _jobs[itemIndex];
                final accent = accentColors[itemIndex % accentColors.length];
                return JobCard(
                  data: item,
                  accent: accent,
                  cardColor: cardColor,
                  cardBorder: cardBorder,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  showShadow: !isDark,
                );
              }, childCount: _jobs.isEmpty ? 0 : (_jobs.length * 2) - 1),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.textPrimary,
    required this.textMuted,
    required this.accent,
    required this.onAccent,
    required this.cardColor,
    required this.cardBorder,
  });

  final Color textPrimary;
  final Color textMuted;
  final Color accent;
  final Color onAccent;
  final Color cardColor;
  final Color cardBorder;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: cardBorder),
          ),
          child: Center(
            child: Text(
              'G',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Guy Hawkins',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: onAccent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Post a Job',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.data,
    required this.accent,
    required this.cardColor,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.showShadow,
  });

  final JobCardData data;
  final Color accent;
  final Color cardColor;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AppSvgIcon(assetName: AppIcon.techCompany1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.company} | ${data.date}',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              AppSvgIcon(assetName: AppIcon.more, color: textPrimary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.description,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textMuted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class JobCardData {
  const JobCardData({
    required this.title,
    required this.company,
    required this.date,
    required this.description,
  });

  final String title;
  final String company;
  final String date;
  final String description;
}
