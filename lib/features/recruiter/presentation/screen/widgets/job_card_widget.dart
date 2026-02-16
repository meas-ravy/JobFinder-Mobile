import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/data/models/job_card_data.dart';
import 'package:job_finder/l10n/app_localizations.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    data.logo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.business, size: 24);
                    },
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
                        Flexible(
                          child: Text(
                            _capitalize(data.title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (data.status.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildStatusBadge(context, data.status),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(data),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.8,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                enabled: !isLoading,
                icon: Icon(
                  Icons.more_vert,
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
                  if (data.status == 'Draft') {
                    return [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit_outlined, size: 20),
                            const SizedBox(width: 12),
                            Text(l10n.editJob),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.delete_outline,
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
                    PopupMenuItem(
                      value: 'Filled',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: AppColor.findJob,
                          ),
                          const SizedBox(width: 12),
                          const Text('Mark as Filled'),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (data.salaryMin != null)
                  _buildInfoTag(
                    context,
                    Icons.payments_outlined,
                    _buildSalaryString(data),
                    colorScheme.primary,
                  ),
                if (data.employmentType != null)
                  _buildInfoTag(
                    context,
                    Icons.work_outline_rounded,
                    data.employmentType!,
                    Colors.orange,
                  ),
                if (data.workArrangement != null)
                  _buildInfoTag(
                    context,
                    Icons.location_on_outlined,
                    data.workArrangement!,
                    Colors.blue,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 60),
            child: Text(
              data.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (data.status == 'Draft') ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 60),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (onStatusUpdate != null) {
                            onStatusUpdate!('submit');
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
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    isLoading ? 'Submitting...' : 'Submit for Review',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
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
    final min = data.salaryMin! >= 1000
        ? '${(data.salaryMin! / 1000).toStringAsFixed(1)}k'
        : '${data.salaryMin}';
    final max = data.salaryMax != null
        ? (data.salaryMax! >= 1000
              ? '${(data.salaryMax! / 1000).toStringAsFixed(1)}k'
              : '${data.salaryMax}')
        : '';
    final currency = data.salaryCurrency ?? 'USD';

    if (max.isNotEmpty) {
      return '$min - $max $currency';
    }
    return '$min $currency';
  }

  Widget _buildInfoTag(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitle(JobCardData data) {
    final parts = <String>[];
    if (data.company.isNotEmpty) parts.add(data.company);
    if (data.location.isNotEmpty) parts.add(data.location);

    String subtitle = parts.join(' • ');
    if (data.time.isNotEmpty) {
      subtitle += ' | ${data.time}';
    }
    return subtitle;
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = AppColor.appliedLight.withValues(alpha: 0.1);
        textColor = AppColor.appliedLight;
        break;
      case 'draft':
        bgColor = colorScheme.secondaryContainer.withValues(alpha: 0.5);
        textColor = colorScheme.onSecondaryContainer;
        break;
      case 'paused':
        bgColor = AppColor.findJob.withValues(alpha: 0.1);
        textColor = AppColor.findJob;
        break;
      case 'closed':
        bgColor = AppColor.errorLight.withValues(alpha: 0.1);
        textColor = AppColor.errorLight;
        break;
      case 'filled':
        bgColor = colorScheme.primary.withValues(alpha: 0.1);
        textColor = colorScheme.primary;
        break;
      default:
        bgColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
        textColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
