import 'package:flutter/material.dart';
import 'package:job_finder/features/recruiter/presentation/data/applies_data.dart';
import 'package:job_finder/features/recruiter/presentation/widget/applicant_card.dart';
import 'package:job_finder/features/recruiter/presentation/widget/header_section.dart';

class RecruiterAppliedPage extends StatelessWidget {
  const RecruiterAppliedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final cardColor = isDark
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
        : colorScheme.surface;
    final cardBorder = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.3 : 0.4,
    );
    final textPrimary = colorScheme.onSurface;
    final textMuted = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.6 : 0.7,
    );
    final chips = buildAttachmentPalette(colorScheme);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: const HeaderSection(),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: applicants.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = applicants[index];
          return ApplicantCard(
            data: item,
            cardColor: cardColor,
            cardBorder: cardBorder,
            textPrimary: textPrimary,
            textMuted: textMuted,
            palette: chips,
          );
        },
      ),
    );
  }
}
