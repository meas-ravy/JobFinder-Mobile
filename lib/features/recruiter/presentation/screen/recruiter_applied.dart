import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/features/recruiter/presentation/data/applies_data.dart';
import 'package:job_finder/features/recruiter/presentation/widget/applicant_card.dart';

class RecruiterAppliedPage extends StatelessWidget {
  const RecruiterAppliedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = scheme.surfaceContainerHighest;
    final cardBorder = scheme.outlineVariant.withValues(
      alpha: isDark ? 0.6 : 0.4,
    );
    final textPrimary = scheme.onSurface;
    final textMuted = scheme.onSurface.withValues(alpha: isDark ? 0.6 : 0.7);
    final chips = buildAttachmentPalette(scheme);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Applied',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: applicants.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}
