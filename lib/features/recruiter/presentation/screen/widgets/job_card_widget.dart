import 'package:flutter/material.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/data/models/job_card_data.dart';
import 'package:job_finder/l10n/app_localizations.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';

class JobCard extends StatelessWidget {
  const JobCard({
    super.key,
    required this.data,
    this.onStatusUpdate,
    this.isLoading = false,
  });

  final JobCardData data;
  final Function(String)? onStatusUpdate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light
            ? Colors.white
            : AppColor.cardDark,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: colorScheme.brightness == Brightness.light
              ? colorScheme.outline.withValues(alpha: 0.1)
              : AppColor.cardDark,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.brightness == Brightness.light
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      data.logo,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.business, size: 30);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(data.title),
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.company,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  enabled: !isLoading,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 28,
                  ),
                  onSelected: (value) {
                    if (onStatusUpdate != null) {
                      onStatusUpdate!(value);
                    }
                  },
                  itemBuilder: (context) {
                    final l10n = AppLocalizations.of(context);
                    if (data.status == 'Draft' || data.status == 'Rejected') {
                      return [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              AppSvgIcon(
                                assetName: AppIcon.edit,
                                color: colorScheme.onSurface,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(l10n.editJob),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              AppSvgIcon(
                                assetName: AppIcon.delete,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                l10n.deleteJob,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        if (data.status == 'Rejected')
                          const PopupMenuItem(
                            value: 'resubmit',
                            child: Row(
                              children: [
                                Icon(Icons.send_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Resubmit'),
                              ],
                            ),
                          ),
                      ];
                    }

                    if (data.status == 'Paused') {
                      return [
                        const PopupMenuItem(
                          value: 'Active',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline_rounded,
                                size: 20,
                                color: Colors.green,
                              ),
                              SizedBox(width: 12),
                              Text('Resume Job'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Closed',
                          child: Row(
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                size: 20,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              const Text('Close Job'),
                            ],
                          ),
                        ),
                      ];
                    }

                    if (data.status == 'Pending') {
                      return [
                        PopupMenuItem(
                          enabled: false,
                          child: Row(
                            children: [
                              Icon(
                                Icons.hourglass_top_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Pending Review',
                                style: TextStyle(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ];
                    }

                    if (data.status == 'Closed') {
                      return [
                        PopupMenuItem(
                          value: 'view_candidates',
                          child: Row(
                            children: [
                              const Icon(Icons.people_outline, size: 20),
                              const SizedBox(width: 12),
                              const Text('View Candidates'),
                            ],
                          ),
                        ),
                      ];
                    }

                    return [
                      PopupMenuItem(
                        value: 'Paused',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pause_circle_outline,
                              size: 20,
                              color: AppColor.appliedLight,
                            ),
                            const SizedBox(width: 12),
                            const Text('Pause Job'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Closed',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cancel_outlined,
                              size: 20,
                              color: AppColor.errorLight,
                            ),
                            const SizedBox(width: 12),
                            const Text('Close Job'),
                          ],
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(
              color: colorScheme.brightness == Brightness.light
                  ? colorScheme.outline.withValues(alpha: 0.05)
                  : colorScheme.outline.withValues(alpha: 0.1),
            ),
            const SizedBox(height: 16),

            // Center Info Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.location,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (data.salaryMin != null &&
                    (data.salaryMin! > 0 || (data.salaryMax ?? 0) > 0))
                  Text(
                    _buildSalaryString(data),
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Bottom Tags
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  if (data.employmentType != null)
                    _buildOutlineTag(context, data.employmentType!),
                  if (data.workArrangement != null)
                    _buildOutlineTag(context, data.workArrangement!),

                  if (data.status == 'Rejected' &&
                      data.rejectionReason != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: colorScheme.error,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rejection Reason',
                                style: textTheme.labelMedium?.copyWith(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data.rejectionReason!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (data.status == 'Pending') ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_top_rounded,
                      color: colorScheme.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Review',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Loading indicator for cards that don't have a bottom action button
            if (isLoading &&
                data.status != 'Draft' &&
                data.status != 'Paused' &&
                data.status != 'Rejected') ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Processing...',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (data.status == 'Draft' ||
                data.status == 'Paused' ||
                data.status == 'Rejected') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (onStatusUpdate != null) {
                            if (data.status == 'Paused') {
                              onStatusUpdate!('Active');
                            } else {
                              onStatusUpdate!('submit');
                            }
                          }
                        },
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          data.status == 'Paused'
                              ? Icons.play_circle_outline_rounded
                              : Icons.send_rounded,
                          size: 18,
                        ),
                  label: Text(
                    isLoading
                        ? (data.status == 'Paused'
                              ? 'Resuming...'
                              : (data.status == 'Rejected'
                                    ? 'Resubmitting...'
                                    : 'Submitting...'))
                        : (data.status == 'Paused'
                              ? 'Resume Job'
                              : (data.status == 'Rejected'
                                    ? 'Resubmit for Review'
                                    : 'Submit for Review')),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: data.status == 'Paused'
                        ? Colors.green
                        : colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutlineTag(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDarkSecondary : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? null
            : Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isDark
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _buildSalaryString(JobCardData data) {
    if (data.salaryMin == null) return '';

    // If both min and max are 0, treat as negotiable
    if (data.salaryMin == 0 &&
        (data.salaryMax == null || data.salaryMax == 0)) {
      return 'Negotiable';
    }

    final min = data.salaryMin! >= 1000
        ? '${(data.salaryMin! / 1000).toStringAsFixed(1)}k'
        : '${data.salaryMin}';
    final max = data.salaryMax != null && data.salaryMax! > 0
        ? (data.salaryMax! >= 1000
              ? '${(data.salaryMax! / 1000).toStringAsFixed(1)}k'
              : '${data.salaryMax}')
        : '';
    final period = data.salaryPeriod ?? 'month';

    if (max.isNotEmpty) {
      return '\$$min - \$$max /$period';
    }
    return '\$$min /$period';
  }
}
