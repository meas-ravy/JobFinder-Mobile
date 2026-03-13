import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/features/recruiter/data/models/applicant_card_data.dart';
import 'package:job_finder/features/recruiter/presentation/provider/applications/recruiter_applications_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/application_shimmer.dart';
import 'package:job_finder/features/recruiter/presentation/widget/applicant_card.dart';

class RecruiterAppliedPage extends ConsumerStatefulWidget {
  const RecruiterAppliedPage({super.key, this.jobId});
  final String? jobId;

  @override
  ConsumerState<RecruiterAppliedPage> createState() =>
      _RecruiterAppliedPageState();
}

class _RecruiterAppliedPageState extends ConsumerState<RecruiterAppliedPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keeps the tab alive in the PageView!

  Map<String, Color> _buildAttachmentPalette(ColorScheme scheme) {
    return {
      'Resume': scheme.primary,
      'Cover Letter': scheme.secondary,
      'CV': scheme.tertiary,
      'Portfolio': scheme.primary,
    };
  }

  @override
  void initState() {
    super.initState();
    // Only fetch if we don't already have data, to prevent calling the API over and over
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(recruiterApplicationsControllerProvider);
      if (state.applicants.isEmpty) {
        if (widget.jobId != null) {
          ref
              .read(recruiterApplicationsControllerProvider.notifier)
              .getJobApplications(widget.jobId!);
        } else {
          ref
              .read(recruiterApplicationsControllerProvider.notifier)
              .getAllApplications();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required by AutomaticKeepAliveClientMixin

    final colorScheme = Theme.of(context).colorScheme;
    final recruiterState = ref.watch(recruiterApplicationsControllerProvider);

    // Shared refresh callback
    Future<void> onRefresh() async {
      if (widget.jobId != null) {
        await ref
            .read(recruiterApplicationsControllerProvider.notifier)
            .getJobApplications(widget.jobId!, refresh: true);
      } else {
        await ref
            .read(recruiterApplicationsControllerProvider.notifier)
            .getAllApplications(refresh: true);
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Applications')),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: buildBody(context, recruiterState, colorScheme, onRefresh),
      ),
    );
  }

  Widget buildBody(
    BuildContext context,
    RecruiterApplicationsState state,
    ColorScheme colorScheme,
    void Function()? onPressed,
  ) {
    // 1. Loading state (only if we don't have existing data to show)
    if (state.isLoading && state.applicants.isEmpty) {
      return const AppliedShimmer();
    }

    // 2. Error state (only if we don't have data to fall back on)
    if (state.errorMessage != null && state.applicants.isEmpty) {
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
                  state.errorMessage ?? 'Failed to load applications',
                  style: TextStyle(color: colorScheme.error),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: onPressed, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    // 3. Empty state (not loading, no error, and no data)
    if (!state.isLoading && state.applicants.isEmpty) {
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

    // 4. Content state (show list if we have data, even if still loading in background)

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: state.applicants.length,
      separatorBuilder: (context, index) =>
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
      itemBuilder: (context, index) {
        final application = state.applicants[index];
        final isDark = colorScheme.brightness == Brightness.dark;
        final textPrimary = colorScheme.onSurface;

        // Parse date
        String dateStr = 'Just now';
        try {
          final now = DateTime.now();
          final diff = now.difference(application.submittedAt);
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

        final displayData = ApplicantCardData(
          name: application.jobSeeker.fullName,
          avatarUrl: application.jobSeeker.avatarUrl,
          date: dateStr,
          role: application.job.title,
          snippet: 'Interested in this position',
          attachments: [
            if (application.resumeUrl.isNotEmpty)
              const AttachmentData(
                label: 'Resume',
                icon: Icons.description_outlined,
              ),
          ],
        );

        return InkWell(
          onTap: () {
            context.push(
              '${AppPath.applicationDetail}/${application.id}',
            );
          },
          child: ApplicantCard(
            data: displayData,
            cardBorder: colorScheme.outlineVariant.withValues(
              alpha: isDark ? 0.3 : 0.4,
            ),
            textPrimary: textPrimary,
            textMuted: colorScheme.onSurface.withValues(
              alpha: isDark ? 0.6 : 0.7,
            ),
            palette: _buildAttachmentPalette(colorScheme),
          ),
        );
      },
    );
  }
}
