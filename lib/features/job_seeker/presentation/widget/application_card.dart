import 'package:flutter/material.dart';
import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationEntity application;

  const ApplicationCard({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final job = application.job;
    final company = job?.companyProfile;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
            child: company?.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      company!.logoUrl!,
                      fit: BoxFit.contain,
                    ),
                  )
                : const Icon(Icons.business, color: Colors.grey),
          ),

          const SizedBox(width: 24),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job?.title ?? 'Unknown Position',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      company?.name ?? 'Unknown Company',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),

                const SizedBox(height: 12),

                _buildStatusBadge(application.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'submitted':
      case 'application sent':
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue[700]!;
        label = 'Application Sent';
        break;
      case 'application accepted':
        bgColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green[700]!;
        label = 'Application Accepted';
        break;
      case 'application rejected':
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red[700]!;
        label = 'Application Rejected';
        break;
      case 'application pending':
      default:
        bgColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange[700]!;
        label = 'Application Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
