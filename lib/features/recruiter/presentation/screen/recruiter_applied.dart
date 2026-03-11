import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/features/recruiter/data/models/applicant_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/widget/applicant_card.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';

class RecruiterAppliedPage extends HookConsumerWidget {
  const RecruiterAppliedPage({super.key, this.jobId});

  final String? jobId;

  Map<String, Color> _buildAttachmentPalette(ColorScheme scheme) {
    return {
      'Resume': scheme.primary,
      'Cover Letter': scheme.secondary,
      'CV': scheme.tertiary,
      'Portfolio': scheme.primary,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final recruiterState = ref.watch(recruiterControllerProvider);
    final isDark = colorScheme.brightness == Brightness.dark;

    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (!context.mounted) return;
        ref.read(recruiterControllerProvider.notifier).clearApplicants();
        if (jobId != null) {
          ref
              .read(recruiterControllerProvider.notifier)
              .getJobApplications(jobId!);
        } else {
          ref.read(recruiterControllerProvider.notifier).getAllApplications();
        }
      });
      return () {
        // Clear on unmount to prevent data leaking to next screen
        ref.read(recruiterControllerProvider.notifier).clearApplicants();
      };
    }, [jobId]);

    final cardBorder = colorScheme.outlineVariant.withValues(
      alpha: isDark ? 0.3 : 0.4,
    );
    final textPrimary = colorScheme.onSurface;
    final textMuted = colorScheme.onSurface.withValues(
      alpha: isDark ? 0.6 : 0.7,
    );
    final chips = _buildAttachmentPalette(colorScheme);

    // Shared refresh callback
    Future<void> onRefresh() async {
      if (jobId != null) {
        await ref
            .read(recruiterControllerProvider.notifier)
            .getJobApplications(jobId!, refresh: true);
      } else {
        await ref
            .read(recruiterControllerProvider.notifier)
            .getAllApplications(refresh: true);
      }
    }

    // Dynamic body based on state
    Widget buildBody() {
      if (recruiterState.isLoading) {
        return const _AppliedShimmer();
      }

      if (recruiterState.errorMessage != null &&
          recruiterState.applicants.isEmpty) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load applications',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: onRefresh, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        );
      }

      if (recruiterState.applicants.isEmpty) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_ind_outlined,
                    size: 60,
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No applications yet',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pull down to refresh',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.35),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: recruiterState.applicants.length,
        separatorBuilder: (context, index) =>
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
        itemBuilder: (context, index) {
          final itemMap = recruiterState.applicants[index];
          final item = (itemMap is Map)
              ? Map<String, dynamic>.from(itemMap)
              : <String, dynamic>{};

          final userMap = item['jobSeeker'] ?? item['user'];
          final user = (userMap is Map)
              ? Map<String, dynamic>.from(userMap)
              : <String, dynamic>{};

          final jobMap = item['job'];
          final job = (jobMap is Map)
              ? Map<String, dynamic>.from(jobMap)
              : <String, dynamic>{};

          // Parse date if available
          String dateStr = 'Just now';
          final rawDate = item['submittedAt'] ?? item['createdAt'];
          if (rawDate != null) {
            try {
              final date = DateTime.parse(rawDate.toString());
              final now = DateTime.now();
              final diff = now.difference(date);
              if (diff.inDays > 0) {
                dateStr = '${diff.inDays}d ago';
              } else if (diff.inHours > 0) {
                dateStr = '${diff.inHours}h ago';
              } else if (diff.inMinutes > 0) {
                dateStr = '${diff.inMinutes}m ago';
              } else {
                dateStr = 'Just now';
              }
            } catch (_) {}
          }

          final profile = (user['profile'] is Map)
              ? Map<String, dynamic>.from(user['profile'] as Map)
              : <String, dynamic>{};

          final name =
              (profile['fullName'] ??
                      profile['name'] ??
                      user['fullName'] ??
                      user['name'])
                  ?.toString();

          final avatarUrl = (profile['avatarUrl'] ?? user['avatarUrl'])
              ?.toString();

          final displayData = ApplicantCardData(
            name: name ?? 'Unknown Candidate',
            avatarUrl: avatarUrl,
            date: dateStr,
            role: job['title']?.toString() ?? 'Applying for Role',
            snippet:
                item['coverLetter']?.toString() ??
                user['email']?.toString() ??
                'Interested in this position',
            attachments: [
              if (item['resumeUrl'] != null)
                const AttachmentData(
                  label: 'Resume',
                  icon: Icons.description_outlined,
                ),
            ],
          );

          return InkWell(
            onTap: () {
              context.push(
                '${AppPath.applicationDetail}/${item['id']?.toString()}',
              );
            },
            child: ApplicantCard(
              data: displayData,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textMuted: textMuted,
              palette: chips,
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Applications')),
      body: RefreshIndicator(onRefresh: onRefresh, child: buildBody()),
    );
  }
}

class _AppliedShimmer extends StatelessWidget {
  const _AppliedShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: 6,
      separatorBuilder: (context, index) => Divider(
        color: Theme.of(
          context,
        ).colorScheme.outlineVariant.withValues(alpha: 0.2),
      ),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerCircle(radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        ShimmerLoading(width: 120, height: 16),
                        ShimmerLoading(width: 50, height: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const ShimmerLoading(width: 180, height: 12),
                    const SizedBox(height: 8),
                    const ShimmerLoading(width: 140, height: 14),
                    const SizedBox(height: 12),
                    Row(
                      children: const [
                        ShimmerLoading(width: 80, height: 24, borderRadius: 20),
                        SizedBox(width: 8),
                        Spacer(),
                        ShimmerLoading(width: 16, height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
