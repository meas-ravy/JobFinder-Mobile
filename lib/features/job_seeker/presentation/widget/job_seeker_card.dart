import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/routes/app_path.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';

class JobSeekerCard extends StatelessWidget {
  final JobEntity job;
  final bool isHorizontal;

  const JobSeekerCard({
    super.key,
    required this.job,
    this.isHorizontal = false,
  });

  String _formatSalary() {
    String currency = job.salaryCurrency == 'USD'
        ? '\$'
        : (job.salaryCurrency ?? '\$');
    final period = job.salaryPeriod ?? 'month';

    if (job.salaryMin == null || job.salaryMax == null) {
      if (job.salaryFixed != null) {
        final fixedFormatted = job.salaryFixed!
            .toInt()
            .toString()
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
        return '$currency$fixedFormatted /$period';
      }
      return 'Salary negotiable';
    }

    final minFormatted = job.salaryMin!.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    final maxFormatted = job.salaryMax!.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$currency$minFormatted - $currency$maxFormatted /$period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => context.push(AppPath.jobDetail, extra: job.id),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Logo
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color.fromARGB(255, 59, 62, 69)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        (job.companyProfile?.logoUrl != null &&
                            job.companyProfile!.logoUrl!.isNotEmpty)
                        ? Image.network(
                            job.companyProfile!.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildLogoFallback(isDark),
                          )
                        : _buildLogoFallback(isDark),
                  ),
                ),
                const SizedBox(width: 12),
                // Job Title & Company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.companyProfile?.name ?? 'Unknown Company',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Bookmark Component
                Consumer(
                  builder: (context, ref, child) {
                    final savedOverride = ref.watch(
                      jobSavedStatusProvider(job.id),
                    );
                    final isSaved = savedOverride ?? job.isSaved ?? false;

                    return IconButton(
                      onPressed: () async {
                        try {
                          // Optimistic update
                          ref
                                  .read(jobSavedStatusProvider(job.id).notifier)
                                  .state =
                              !isSaved;

                          final result = await ref
                              .read(saveJobUseCaseProvider)
                              .call(job.id);

                          // Sync with result
                          ref
                                  .read(jobSavedStatusProvider(job.id).notifier)
                                  .state =
                              result;

                          if (context.mounted) {
                            _showSavedNotification(
                              context,
                              Theme.of(context).brightness == Brightness.dark,
                              result,
                            );
                          }

                          // Refresh saved jobs list only
                          ref.invalidate(savedJobsProvider);
                        } catch (e) {
                          // Rollback
                          ref
                                  .read(jobSavedStatusProvider(job.id).notifier)
                                  .state =
                              isSaved;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      icon: AppSvgIcon(
                        assetName: isSaved ? AppIcon.saveBold : AppIcon.save,
                        color: AppColor.primaryDark,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                thickness: 1,
              ),
            ),

            // Location
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  job.location ?? 'Remote',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Salary
            Text(
              _formatSalary(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColor.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (job.employmentType != null) ...[
                  _buildTag(context, job.employmentType!, isDark),
                  const SizedBox(width: 8),
                ],
                if (job.workArrangement != null)
                  _buildTag(context, job.workArrangement!, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedNotification(BuildContext context, bool isDark, bool isSaved) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColor.primaryDark.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSaved ? AppColor.primaryDark : Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSaved ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  isSaved ? 'Job Saved!' : 'Job Unsaved',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget _buildLogoFallback(bool isDark) {
    return Icon(
      Icons.business,
      color: isDark ? Colors.grey[600] : Colors.grey[400],
      size: 32,
    );
  }

  Widget _buildTag(BuildContext context, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark ? Colors.grey[300] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
