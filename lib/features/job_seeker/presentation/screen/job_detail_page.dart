import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:share_plus/share_plus.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_detail/job_detail_tabs.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_detail/apply_bottom_sheet.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_detail/job_detail_shimmer.dart';
import 'package:job_finder/features/job_seeker/presentation/widget/job_detail/saved_notification_overlay.dart';

class JobDetailPage extends ConsumerWidget {
  final String jobId;

  const JobDetailPage({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final jobAsync = ref.watch(jobDetailProvider(jobId));
    final savedOverride = ref.watch(jobSavedStatusProvider(jobId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 26,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          jobAsync.when(
            data: (job) {
              final isSaved = savedOverride ?? job.isSaved ?? false;
              return IconButton(
                icon: AppSvgIcon(
                  assetName: isSaved ? AppIcon.saveBold : AppIcon.save,
                  color: isSaved
                      ? AppColor.primaryDark
                      : theme.colorScheme.onSurface,
                  size: 26,
                ),
                onPressed: () async {
                  try {
                    // Optimistic update
                    ref.read(jobSavedStatusProvider(jobId).notifier).state =
                        !isSaved;

                    final result = await ref
                        .read(saveJobUseCaseProvider)
                        .call(job.id);

                    // Sync with actual result
                    ref.read(jobSavedStatusProvider(jobId).notifier).state =
                        result;

                    if (context.mounted) {
                      SavedNotificationOverlay.show(context, isDark, result);
                    }

                    // Refresh in background
                    ref.invalidate(savedJobsProvider);
                  } catch (e) {
                    // Rollback
                    ref.read(jobSavedStatusProvider(jobId).notifier).state =
                        isSaved;
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
              );
            },
            loading: () => IconButton(
              icon: AppSvgIcon(assetName: AppIcon.save, size: 26),
              onPressed: null,
            ),
            error: (_, _) => IconButton(
              icon: AppSvgIcon(assetName: AppIcon.save, size: 26),
              onPressed: null,
            ),
          ),
          jobAsync.when(
            data: (job) => IconButton(
              icon: Icon(
                Icons.share_outlined,
                size: 26,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () {
                final shareUrl =
                    job.shareUrl ?? 'https://jober-world.com/jobs/${job.id}';
                final title = job.title;
                final company = job.companyProfile?.name ?? 'a great company';
                // ignore: deprecated_member_use
                Share.share(
                  'Check out this opening for $title at $company!\n\nView details here: $shareUrl',
                  subject: 'Job Opportunity: $title',
                );
              },
            ),
            loading: () => const IconButton(
              icon: Icon(Icons.share_outlined, size: 26),
              onPressed: null,
            ),
            error: (_, _) => const IconButton(
              icon: Icon(Icons.share_outlined, size: 26),
              onPressed: null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: jobAsync.when(
        data: (job) => JobDetailTabs(job: job, isDark: isDark, theme: theme),
        loading: () => JobDetailShimmer(isDark: isDark),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: jobAsync.when(
        data: (job) => _buildBottomButton(context, isDark),
        loading: () => const SizedBox.shrink(),
        error: (err, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColor.backgroundColorDark : Colors.white,
      ),
      child: ElevatedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => ApplyBottomSheet(isDark: isDark),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primaryDark,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Apply',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
