import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/data/applies_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/widget/applicant_card.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/helper/typedef.dart';

class RecruiterAppliedPage extends HookConsumerWidget {
  const RecruiterAppliedPage({super.key, this.jobId});

  final String? jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final recruiterState = ref.watch(recruiterControllerProvider);
    final isDark = colorScheme.brightness == Brightness.dark;

    useEffect(() {
      if (jobId != null) {
        Future.delayed(Duration.zero, () {
          ref
              .read(recruiterControllerProvider.notifier)
              .getJobApplications(jobId!);
        });
      }
      return null;
    }, [jobId]);

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
        title: const Text('Applications'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      body: recruiterState.isLoading
          ? const _AppliedShimmer()
          : recruiterState.applicants.isEmpty
          ? const Center(child: Text('No applications yet'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: recruiterState.applicants.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = recruiterState.applicants[index] as DataMap;
                final user = item['user'] as DataMap? ?? {};

                // Adapt real data to ApplicantCardData for visual rendering
                final displayData = ApplicantCardData(
                  name: user['name']?.toString() ?? 'Unknown',
                  date:
                      'Just now', // You might want to parse createdAt if available
                  role: 'Applicant',
                  snippet:
                      item['coverLetter']?.toString() ??
                      'Interested in this position',
                  attachments: [
                    const AttachmentData(
                      label: 'Resume',
                      icon: Icons.description_outlined,
                    ),
                  ],
                );

                return ApplicantCard(
                  data: displayData,
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

class _AppliedShimmer extends StatelessWidget {
  const _AppliedShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerCircle(radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ShimmerLoading(width: 100, height: 16),
                            ShimmerLoading(width: 60, height: 12),
                          ],
                        ),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 200, height: 14),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            ShimmerLoading(
                              width: 70,
                              height: 24,
                              borderRadius: 12,
                            ),
                            SizedBox(width: 8),
                            ShimmerLoading(
                              width: 70,
                              height: 24,
                              borderRadius: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
