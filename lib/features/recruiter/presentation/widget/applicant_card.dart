import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/features/recruiter/data/models/applicant_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/widget/chip_widget.dart';

class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    required this.data,
    required this.cardBorder,
    required this.textPrimary,
    required this.textMuted,
    required this.palette,
  });

  final ApplicantCardData data;
  final Color cardBorder;
  final Color textPrimary;
  final Color textMuted;
  final Map<String, Color> palette;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: palette['Resume']?.withValues(alpha: 0.15),
                backgroundImage: data.avatarUrl != null
                    ? NetworkImage(data.avatarUrl!)
                    : null,
                child: data.avatarUrl == null
                    ? Text(
                        data.name.substring(0, 1),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      )
                    : null,
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
                    const SizedBox(height: 2),

                    Text(
                      'Contact: ${data.snippet}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Applied for: ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: textMuted,
                            height: 1.35,
                          ),
                        ),

                        Expanded(
                          child: Text(
                            data.role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons.arrow_forward_ios,
                          color: textMuted,
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: data.attachments
                          .map(
                            (attachment) => AttachmentChip(
                              label: attachment.label,
                              icon: Padding(
                                padding: const EdgeInsets.all(2),
                                child: Image.asset(
                                  AppIcon.pdf,
                                  height: 16,
                                  width: 18,
                                ),
                              ),
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
