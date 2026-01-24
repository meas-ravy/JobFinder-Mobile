import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/features/recruiter/presentation/data/applies_data.dart';
import 'package:job_finder/features/recruiter/presentation/widget/chip_widget.dart';

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.data,
    required this.cardColor,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.palette,
  });

  final ApplicantCardData data;
  final Color cardColor;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Map<String, Color> palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette['Resume']?.withValues(alpha: 0.15),
                child: Text(
                  data.name.substring(0, 1),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.name,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          data.date,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Applied for ${data.role}, ${data.snippet}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.attachments
                          .map(
                            (attachment) => AttachmentChip(
                              label: attachment.label,
                              icon: attachment.icon,
                              color:
                                  palette[attachment.label] ??
                                  palette['Resume']!,
                              textColor: textMuted,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
