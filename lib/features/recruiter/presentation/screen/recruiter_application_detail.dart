import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';
import 'package:job_finder/shared/widget/shimmer_loading.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/presentation/screen/recruiter_chat_detail.dart';
import 'package:job_finder/core/services/firebase_chat_service.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';

class RecruiterApplicationDetailPage extends HookConsumerWidget {
  const RecruiterApplicationDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recruiterState = ref.watch(recruiterControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    useEffect(() {
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ref
              .read(recruiterControllerProvider.notifier)
              .getApplicationDetails(id);
        }
      });
      return null;
    }, [id]);

    ref.listen(recruiterControllerProvider, (previous, next) {
      if (next.lastAction == RecruiterAction.updateApplicationStatus &&
          !next.isLoading &&
          previous?.isLoading == true) {
        if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: colorScheme.error,
            ),
          );
        } else {
          _showSuccessSheet(context, ref, id);
        }
      }
    });

    if (recruiterState.isLoading && recruiterState.applicationDetails == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Application Details',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerCircle(radius: 40),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ShimmerLoading(width: 180, height: 28),
                        SizedBox(height: 8),
                        ShimmerLoading(width: 140, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const ShimmerLoading(width: 120, height: 18),
              const SizedBox(height: 12),
              ShimmerLoading(
                width: double.infinity,
                height: 80,
                borderRadius: 16,
              ),
              const SizedBox(height: 32),
              const ShimmerLoading(width: 150, height: 18),
              const SizedBox(height: 16),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: const [
                      ShimmerCircle(radius: 10),
                      SizedBox(width: 12),
                      ShimmerLoading(width: 80, height: 14),
                      Spacer(),
                      ShimmerLoading(width: 100, height: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Row(
                children: const [
                  Expanded(child: ShimmerLoading(width: 100, height: 50)),
                  SizedBox(width: 16),
                  Expanded(child: ShimmerLoading(width: 100, height: 50)),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (recruiterState.errorMessage != null &&
        recruiterState.applicationDetails == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                recruiterState.errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(recruiterControllerProvider.notifier)
                    .getApplicationDetails(id),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final application = recruiterState.applicationDetails;
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    final jobSeekerMap = application['jobSeeker'] ?? application['user'];
    final jobSeeker = (jobSeekerMap is Map)
        ? DataMap.from(jobSeekerMap)
        : <String, dynamic>{};

    final profileMap = jobSeeker['profile'];
    final profile = (profileMap is Map)
        ? DataMap.from(profileMap)
        : <String, dynamic>{};

    final jobMap = application['job'];
    final job = (jobMap is Map) ? DataMap.from(jobMap) : <String, dynamic>{};

    final candidateId =
        jobSeeker['_id'] ?? jobSeeker['id'] ?? application['jobSeekerId'] ?? '';
    final jobId = job['_id'] ?? job['id'] ?? application['jobId'] ?? '';

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Application Details'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Header
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profile['avatarUrl'] != null
                      ? NetworkImage(profile['avatarUrl'].toString())
                      : null,
                  child: profile['avatarUrl'] == null
                      ? Text(
                          (profile['fullName']?.toString().isNotEmpty == true)
                              ? profile['fullName']!
                                    .toString()
                                    .substring(0, 1)
                                    .toUpperCase()
                              : 'U',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile['fullName']?.toString() ?? 'Unknown Candidate',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile['email']?.toString() ?? 'No email provided',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStatusBadge(
                        context,
                        application['status']?.toString() ?? 'Pending',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.message_outlined,
                    color: AppColor.primaryLight,
                  ),
                  onPressed: () {
                    // Start or go to conversation
                    // For now, we need to map application to conversationId
                    // Usually conversationId is provided in the application object or fetched via an endpoint
                    // Let's assume conversationId might be in application['conversationId'] or similar
                    final conversationId =
                        application['conversationId']?.toString() ??
                        "conv_${candidateId}_$jobId";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecruiterChatDetailScreen(
                          conversationId: conversationId,
                          candidateName:
                              profile['fullName']?.toString() ?? 'Candidate',
                          candidateAvatar: profile['avatarUrl']?.toString(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Job Applied For
            _buildSection(
              context,
              'Applied For: ',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    AppSvgIcon(
                      assetName: AppIcon.application,
                      size: 30,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job['title']?.toString() ?? 'Unknown Job',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${job['category'] ?? ''} • ${job['employmentType'] ?? ''} • ${job['location'] ?? ''}',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information
            _buildSection(
              context,
              'Personal Information: ',
              child: Column(
                children: [
                  _buildInfoRow(
                    context,
                    Icon(Icons.phone_outlined),
                    'Phone',
                    jobSeeker['phone']?.toString() ?? 'N/A',
                  ),
                  _buildInfoRow(
                    context,
                    Icon(Icons.cake_outlined),
                    'Birthday',
                    _formatDate(profile['dateOfBirth']),
                  ),
                  _buildInfoRow(
                    context,
                    AppSvgIcon(
                      assetName: AppIcon.profile,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    'Gender',
                    profile['gender']?.toString() ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Resume
            if (application['resumeUrl'] != null)
              _buildSection(
                context,
                'Attachments: ',
                child: InkWell(
                  onTap: () =>
                      launchUrl(Uri.parse(application['resumeUrl'].toString())),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Image.asset(AppIcon.pdf, height: 24, width: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Curriculum Vitae (CV)',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Actions
            if (application['status'] == 'Hired' ||
                application['status'] == 'Rejected')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      (application['status'] == 'Hired'
                              ? Colors.green
                              : Colors.red)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        (application['status'] == 'Hired'
                                ? Colors.green
                                : Colors.red)
                            .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      application['status'] == 'Hired'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: application['status'] == 'Hired'
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Candidate already ${application['status']}",
                      style: TextStyle(
                        color: application['status'] == 'Hired'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: recruiterState.isLoading
                          ? null
                          : () => _confirmAction(context, ref, id, 'Rejected'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.error),
                        foregroundColor: colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reject Candidate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: recruiterState.isLoading
                          ? null
                          : () => _confirmAction(context, ref, id, 'Hired'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Hire Candidate',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _confirmAction(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
  ) {
    final application = ref
        .read(recruiterControllerProvider)
        .applicationDetails;
    final jobSeekerMap = application?['jobSeeker'] ?? application?['user'];
    final jobSeeker = (jobSeekerMap is Map)
        ? Map<String, dynamic>.from(jobSeekerMap)
        : <String, dynamic>{};

    final profileMap = jobSeeker['profile'];
    final profile = (profileMap is Map)
        ? Map<String, dynamic>.from(profileMap)
        : <String, dynamic>{};

    final candidateName = profile['fullName'] ?? "this candidate";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          status == 'Hired' ? "Hire Candidate?" : "Reject Candidate?",
        ),
        content: Text(
          "Are you sure you want to $status $candidateName? This action will notify the candidate.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(recruiterControllerProvider.notifier)
                  .updateApplicationStatus(id, status);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Hired' ? Colors.green : Colors.red,
            ),
            child: Text(status, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSheet(BuildContext context, WidgetRef ref, String id) async {
    final state = ref.read(recruiterControllerProvider);
    final application = state.applicationDetails;
    if (application == null) return;

    final jobSeekerMap = application['jobSeeker'] ?? application['user'];
    final jobSeeker = (jobSeekerMap is Map)
        ? DataMap.from(jobSeekerMap)
        : <String, dynamic>{};

    final profileMap = jobSeeker['profile'];
    final profile = (profileMap is Map)
        ? DataMap.from(profileMap)
        : <String, dynamic>{};

    final jobMap = application['job'];
    final job = (jobMap is Map) ? DataMap.from(jobMap) : <String, dynamic>{};
    final status = application['status']?.toString() ?? 'Updated';
    final candidateName = profile['fullName'] ?? "Candidate";
    final isHired = status == 'Hired';

    final candidateId =
        jobSeeker['_id'] ?? jobSeeker['id'] ?? application['jobSeekerId'] ?? '';
    final jobIdVar = job['_id'] ?? job['id'] ?? application['jobId'] ?? '';

    // Send automated message
    try {
      final conversationId =
          application['conversationId']?.toString() ??
          "conv_${candidateId}_$jobIdVar";

      final content = isHired
          ? "Congratulations $candidateName! You have been hired for the ${job['title']} position. We will reach out to you shortly for the next steps."
          : "Hi $candidateName, thank you for your interest in the ${job['title']} position. Unfortunately, we have decided to move forward with other candidates at this time.";

      FirebaseChatService.instance.sendMessage(
        conversationId,
        ChatMessageModel(
          content: content,
          senderId: state.company?.id ?? "recruiter",
          senderType: "User",
          jobId: job['id']?.toString(),
        ),
      );
    } catch (e) {
      debugPrint("Failed to send automated message: $e");
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isHired ? Colors.green : Colors.orange).withOpacity(
                  0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isHired ? Icons.check_circle : Icons.info_outline,
                size: 64,
                color: isHired ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isHired ? "Congratulations!" : "Application Updated",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isHired
                  ? "You have successfully hired $candidateName for ${job['title']}."
                  : "You have rejected $candidateName's application for ${job['title']}.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to list
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    Widget icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    Color bgColor;

    switch (status) {
      case 'Hired':
        color = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
        break;
      case 'Rejected':
        color = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
        break;
      default:
        color = Colors.orange;
        bgColor = Colors.orange.withValues(alpha: 0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dt = DateTime.parse(date.toString());
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'N/A';
    }
  }
}
