import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/application_provider.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder/core/routes/app_path.dart';

class JobSeekerApplicationDetailPage extends HookConsumerWidget {
  final String id;

  const JobSeekerApplicationDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appAsync = ref.watch(applicationDetailsProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application Stages',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: appAsync.when(
        data: (application) {
          final job = application.job;
          final company = job?.companyProfile;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColor.cardDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              width: 1,
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
                              : const Icon(
                                  Icons.business,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          job?.title ?? 'Unknown Position',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          company?.name ?? 'Unknown Company',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (job?.location != null &&
                            job!.location!.isNotEmpty) ...[
                          Text(
                            job.location!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          (job?.salaryMin != null)
                              ? '${job?.salaryCurrency ?? '\$'} ${job!.salaryMin} - ${job.salaryMax ?? ''} /month'
                              : 'Salary not specified',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (job?.employmentType != null)
                              _buildTag(job!.employmentType!, isDark),
                            if (job?.employmentType != null &&
                                job?.workArrangement != null)
                              const SizedBox(width: 8),
                            if (job?.workArrangement != null)
                              _buildTag(job!.workArrangement!, isDark),
                          ],
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Your Application Status',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusBanner(application.status),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomAction(
                context,
                application.status,
                ref,
                application.jobId,
              ),
            ],
          );
        },
        loading: () => _buildLoadingState(isDark),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildTag(String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[300] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'submitted':
      case 'application sent':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue[700]!;
        label = 'Application Sent';
        break;
      case 'hired':
      case 'accepted':
        bgColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        label = 'Application Accepted';
        break;
      case 'rejected':
        bgColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        label = 'Application Rejected';
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        label = 'Application Pending';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    String status,
    WidgetRef ref,
    String jobId,
  ) {
    String labelText;
    VoidCallback? onPressed;

    switch (status.toLowerCase()) {
      case 'hired':
      case 'accepted':
        labelText = 'Send Message to Reviewer';
        onPressed = () {
          context.go('${AppPath.jobSeekerHome}?tab=2');
        };
        break;
      case 'rejected':
        labelText = 'Discover Another Job';
        onPressed = () => context.go('${AppPath.jobSeekerHome}?tab=0');
        break;
      default:
        labelText = 'Waiting...';
        onPressed = null;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              disabledBackgroundColor: Colors.blue[600]?.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              labelText,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColor.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShimmerCircle(radius: 40),
            const SizedBox(height: 24),
            const ShimmerLoading(width: 150, height: 24),
            const SizedBox(height: 12),
            const ShimmerLoading(width: 100, height: 16),
            const SizedBox(height: 24),
            const ShimmerLoading(width: 120, height: 16),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 140, height: 16),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ShimmerLoading(width: 80, height: 32),
                SizedBox(width: 8),
                ShimmerLoading(width: 80, height: 32),
              ],
            ),
            const SizedBox(height: 48),
            const ShimmerLoading(width: 140, height: 16),
            const SizedBox(height: 16),
            ShimmerLoading(
              width: double.infinity,
              height: 56,
              borderRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
