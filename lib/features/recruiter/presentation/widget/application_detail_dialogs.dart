import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/services/firebase_chat_service.dart';
import 'package:job_finder/core/theme/app_color.dart';
import 'package:job_finder/features/recruiter/data/models/chat_message_model.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';

/// Shows the premium confirm bottom sheet (Hire / Reject).
void showConfirmActionSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String id,
  required String status,
  required ValueNotifier<String?> updatingStatus,
  required ValueNotifier<bool> isLoadingDialogOpen,
}) {
  final application = ref
      .read(recruiterApplicationsControllerProvider)
      .applicationDetails;
  
  if (application == null) return;

  final candidateName = application.jobSeeker.fullName;

  final isHire = status == 'Hired';
  final actionColor = isHire
      ? const Color(0xFF10B981)
      : const Color(0xFFF43F5E);
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetCtx) => Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: actionColor.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Glowing icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: actionColor.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: actionColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isHire ? Icons.handshake_rounded : Icons.person_remove_rounded,
              color: actionColor,
              size: 34,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            isHire ? 'Hire Candidate?' : 'Reject Candidate?',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          // Candidate name pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: actionColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_rounded, size: 16, color: actionColor),
                const SizedBox(width: 6),
                Text(
                  candidateName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Subtitle
          Text(
            'This action will notify $candidateName about your decision.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: actionColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(sheetCtx);
                isLoadingDialogOpen.value = true;
                showStatusLoadingDialog(context, isHire);
                updatingStatus.value = status;
                ref
                    .read(recruiterApplicationsControllerProvider.notifier)
                    .updateApplicationStatus(id, status);
              },
              child: Text(
                isHire ? 'Yes, Hire Candidate' : 'Yes, Reject Candidate',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(sheetCtx),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Non-dismissible loading dialog shown while the PATCH request is in-flight.
void showStatusLoadingDialog(BuildContext context, bool isHire) {
  final colorScheme = Theme.of(context).colorScheme;
  final actionColor = isHire
      ? const Color(0xFF10B981)
      : const Color(0xFFF43F5E);

  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogCtx) => PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  valueColor: AlwaysStoppedAnimation<Color>(actionColor),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isHire ? 'Hiring Candidate…' : 'Rejecting Candidate…',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sending notification to candidate',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Success/rejected outcome bottom sheet shown after API responds.
/// Also sends automated Firebase chat messages.
Future<void> showApplicationResultSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String confirmedStatus,
}) async {
  final state = ref.read(recruiterApplicationsControllerProvider);
  final companyState = ref.read(companyProfileProvider);
  final application = state.applicationDetails;
  if (application == null) return;

  final jobSeeker = application.jobSeeker;
  final job = application.job;

  final isHired = confirmedStatus == 'Hired';
  final candidateName = jobSeeker.fullName;
  final candidateId = jobSeeker.id;
  final jobIdVar = job.id;

  // --- Send automated Firebase chat messages ---
  try {
    final conversationId = 'conv_${candidateId}_$jobIdVar';
    final String jobTitle = job.title;
    final content = isHired
        ? 'Congratulations $candidateName! You have been hired for the $jobTitle position. We will reach out to you shortly for the next steps.'
        : 'Hi $candidateName, thank you for your interest in the $jobTitle position. Unfortunately, we have decided to move forward with other candidates at this time.';

    final String companyName = companyState.company?.name ?? 'Company';
    final String jobLocation = job.location;
    
    FirebaseChatService.instance.sendMessage(
      conversationId,
      ChatMessageModel(
        content: 'Job Information Card',
        senderId: FirebaseAuth.instance.currentUser?.uid ?? 'recruiter',
        senderType: 'User',
        type: 'job_card',
        jobData: {
          'title': job.title,
          'company': companyName,
          'location': jobLocation,
          'salary': 'Salary not specified', // We don't have salary in ApplicationJobEntity yet
          'logoUrl': companyState.company?.logoUrl,
        },
      ),
    );

    FirebaseChatService.instance.sendMessage(
      conversationId,
      ChatMessageModel(
        content: content,
        senderId: FirebaseAuth.instance.currentUser?.uid ?? 'recruiter',
        senderType: 'User',
        type: 'text',
        jobId: jobIdVar,
      ),
    );
  } catch (e) {
    debugPrint('Failed to send automated message: $e');
  }

  // --- Show result bottom sheet ---
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * 0.45,
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
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
              color: (isHired ? Colors.green : Colors.orange).withValues(
                alpha: 0.1,
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
            isHired ? 'Congratulations!' : 'Application Updated',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isHired
                ? 'You have successfully hired $candidateName for ${job.title}.'
                : "You have rejected $candidateName's application for ${job.title}.",
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
                Navigator.pop(ctx);
                Navigator.pop(ctx); // Back to list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
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
