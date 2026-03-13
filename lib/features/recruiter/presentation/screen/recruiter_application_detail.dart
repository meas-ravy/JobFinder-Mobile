import 'package:flutter/material.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:job_finder/core/constants/assets.dart';
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
    final recruiterState = ref.watch(recruiterApplicationsControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final updatingStatus = useState<String?>(null);
    final isLoadingDialogOpen = useState(false);

    useEffect(() {
      updatingStatus.value = null;
      Future.delayed(Duration.zero, () {
        if (context.mounted) {
          ref
              .read(recruiterApplicationsControllerProvider.notifier)
              .clearApplicationDetails();
          ref
              .read(recruiterApplicationsControllerProvider.notifier)
              .getApplicationDetails(id);
        }
      });
      return null;
    }, [id]);

    ref.listen(recruiterApplicationsControllerProvider, (previous, next) {
      if (!next.isLoading && previous?.isLoading == true) {
        final wasUpdatingStatus = updatingStatus.value;
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
        } else if (wasUpdatingStatus != null) {
          showApplicationResultSheet(
            context: context,
            ref: ref,
            confirmedStatus: wasUpdatingStatus,
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
                    .read(recruiterApplicationsControllerProvider.notifier)
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

    final jobSeeker = application.jobSeeker;
    final name = jobSeeker.fullName;
    final avatarUrl = jobSeeker.avatarUrl;
    final email = jobSeeker.email;
    final job = application.job;

    // --- Main UI ---
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Application Details'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          name.isNotEmpty
                              ? name.substring(0, 1).toUpperCase()
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
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      buildStatusBadge(context, application.status),
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
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            job.location,
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
                    jobSeeker.phone ?? 'N/A',
                  ),
                  buildInfoRow(
                    context,
                    const Icon(Icons.cake_outlined),
                    'Birthday',
                    jobSeeker.dateOfBirth != null
                        ? '${jobSeeker.dateOfBirth!.day}/${jobSeeker.dateOfBirth!.month}/${jobSeeker.dateOfBirth!.year}'
                        : 'N/A',
                  ),
                  buildInfoRow(
                    context,
                    AppSvgIcon(
                      assetName: AppIcon.profile,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    'Gender',
                    jobSeeker.gender ?? 'N/A',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (application.resumeUrl.isNotEmpty)
              buildSection(
                context,
                'Attachments: ',
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse(application.resumeUrl)),
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

            ApplicationActionButtons(
              application: application,
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
