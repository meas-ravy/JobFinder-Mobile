import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/constants/assets.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';
import 'package:job_finder/shared/widget/svg_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/application_action_buttons.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/application_detail_dialogs.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/application_detail_helpers.dart';
import 'package:job_finder/features/recruiter/presentation/screen/widgets/application_detail_shimmer.dart';

class RecruiterApplicationDetailPage extends HookConsumerWidget {
  const RecruiterApplicationDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recruiterState = ref.watch(recruiterControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final updatingStatus = useState<String?>(null);
    final isLoadingDialogOpen = useState(false);

    useEffect(() {
      updatingStatus.value = null;
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ref
              .read(recruiterControllerProvider.notifier)
              .clearApplicationDetails();
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
        updatingStatus.value = null;

        // Dismiss loading dialog if open
        if (isLoadingDialogOpen.value && context.mounted) {
          isLoadingDialogOpen.value = false;
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          showApplicationResultSheet(
            context: context,
            ref: ref,
            confirmedStatus:
                next.applicationDetails?['status']?.toString() ??
                previous?.applicationDetails?['status']?.toString() ??
                '',
          );
        }
      }
    });

    // --- Loading state ---
    if (recruiterState.isLoading && recruiterState.applicationDetails == null) {
      return const ApplicationDetailShimmer();
    }

    // --- Error state ---
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

    // --- Empty state ---
    final application = recruiterState.applicationDetails;
    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Details')),
        body: const Center(child: Text('No details found')),
      );
    }

    // --- Parse data ---
    final jobSeekerMap = application['jobSeeker'] ?? application['user'];
    final jobSeeker = (jobSeekerMap is Map)
        ? DataMap.from(jobSeekerMap)
        : <String, dynamic>{};
    final profileMap = jobSeeker['profile'];
    final profile = (profileMap is Map)
        ? DataMap.from(profileMap)
        : <String, dynamic>{};

    final name = (profile['fullName'] ??
            profile['name'] ??
            jobSeeker['fullName'] ??
            jobSeeker['name'])
        ?.toString();
    final avatarUrl =
        (profile['avatarUrl'] ?? jobSeeker['avatarUrl'])?.toString();
    final email = (profile['email'] ?? jobSeeker['email'])?.toString();

    final jobMap = application['job'];
    final job = (jobMap is Map) ? DataMap.from(jobMap) : <String, dynamic>{};

    // --- Main UI ---
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Application Details'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Candidate Header ──────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          (name?.isNotEmpty == true)
                              ? name!.substring(0, 1).toUpperCase()
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
                        name ?? 'Unknown Candidate',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email ?? 'No email provided',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildStatusBadge(
                        context,
                        application['status']?.toString() ?? 'Pending',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Job Applied For ───────────────────────────────────────────
            buildSection(
              context,
              'Applied For: ',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      colorScheme.secondaryContainer.withValues(alpha: 0.2),
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

            // ── Personal Information ──────────────────────────────────────
            buildSection(
              context,
              'Personal Information: ',
              child: Column(
                children: [
                  buildInfoRow(
                    context,
                    const Icon(Icons.phone_outlined),
                    'Phone',
                    jobSeeker['phone']?.toString() ?? 'N/A',
                  ),
                  buildInfoRow(
                    context,
                    const Icon(Icons.cake_outlined),
                    'Birthday',
                    formatDate(profile['dateOfBirth']),
                  ),
                  buildInfoRow(
                    context,
                    AppSvgIcon(
                      assetName: AppIcon.profile,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    'Gender',
                    profile['gender']?.toString() ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (application['resumeUrl'] != null)
              buildSection(
                context,
                'Attachments: ',
                child: InkWell(
                  onTap: () => launchUrl(
                    Uri.parse(application['resumeUrl'].toString()),
                  ),
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

            // ── Action Buttons / Decided Banner ───────────────────────────
            ApplicationActionButtons(
              application: Map<String, dynamic>.from(application),
              recruiterState: recruiterState,
              updatingStatus: updatingStatus,
              isLoadingDialogOpen: isLoadingDialogOpen,
              id: id,
              onConfirmAction: (ctx, ref, id, status, upd, loading) =>
                  showConfirmActionSheet(
                    context: ctx,
                    ref: ref,
                    id: id,
                    status: status,
                    updatingStatus: upd,
                    isLoadingDialogOpen: loading,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
