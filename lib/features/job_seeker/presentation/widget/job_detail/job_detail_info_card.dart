import 'package:flutter/material.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:intl/intl.dart';

class JobDetailInfoCard extends StatelessWidget {
  final JobEntity job;
  final bool isDark;
  final ThemeData theme;

  const JobDetailInfoCard({
    super.key,
    required this.job,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final company = job.companyProfile;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColor.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: company?.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      company!.logoUrl!,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Icon(Icons.business, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Job Title
          Text(
            job.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),

          // Company Name
          Text(
            company?.name ?? 'Unknown Company',
            style: const TextStyle(
              color: AppColor.primaryDark,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),

          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          const SizedBox(height: 20),

          // Location
          Text(
            job.location ?? 'No location',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          // Salary
          Text(
            _formatSalaryRange(job),
            style: const TextStyle(
              color: AppColor.primaryDark,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTypeChip(job.employmentType ?? 'Full Time', isDark),
              const SizedBox(width: 10),
              _buildTypeChip(job.workArrangement ?? 'Onsite', isDark),
            ],
          ),
          const SizedBox(height: 16),

          // Posted date
          Text(
            'Posted ${_getTimeAgo(job.createdAt)}, ends in ${_formatDeadline(job.applicationDeadline)}',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.grey[700],
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatSalaryRange(JobEntity job) {
    if (job.salaryMin != null && job.salaryMax != null) {
      // Both 0 → treat as negotiable
      if (job.salaryMin! == 0 && job.salaryMax! == 0) {
        return 'Salary Negotiable';
      }
      final period = job.salaryPeriod?.toLowerCase() ?? 'month';
      return '\$${job.salaryMin!.toInt()} - \$${job.salaryMax!.toInt()} /$period';
    }
    return 'Salary Negotiable';
  }

  String _getTimeAgo(String? dateTimeStr) {
    if (dateTimeStr == null) return 'recently';
    final dateTime = DateTime.parse(dateTimeStr);
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'recently';
  }

  String _formatDeadline(String? deadlineStr) {
    if (deadlineStr == null) return 'Dec 31';
    final date = DateTime.parse(deadlineStr).toLocal();
    return DateFormat('d MMM').format(date);
  }
}
