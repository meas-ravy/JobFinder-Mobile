import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';

/// Shows either the hired/rejected status banner OR the Hire/Reject action buttons.
class ApplicationActionButtons extends StatelessWidget {
  const ApplicationActionButtons({
    super.key,
    required this.application,
    required this.recruiterState,
    required this.updatingStatus,
    required this.isLoadingDialogOpen,
    required this.id,
    required this.onConfirmAction,
  });

  final Map<String, dynamic> application;
  final RecruiterState recruiterState;
  final ValueNotifier<String?> updatingStatus;
  final ValueNotifier<bool> isLoadingDialogOpen;
  final String id;
  final void Function(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
    ValueNotifier<String?> updatingStatus,
    ValueNotifier<bool> isLoadingDialogOpen,
  )
  onConfirmAction;

  bool get _isDecided =>
      application['status'] == 'Hired' ||
      application['status'] == 'Rejected' ||
      updatingStatus.value == 'Hired' ||
      updatingStatus.value == 'Rejected';

  bool get _isHired =>
      application['status'] == 'Hired' || updatingStatus.value == 'Hired';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isDecided) {
      return _DecidedBanner(
        isHired: _isHired,
        updatingStatus: updatingStatus,
        application: application,
      );
    }

    return Consumer(
      builder: (context, ref, _) => Row(
        children: [
          // Reject button
          Expanded(
            child: OutlinedButton(
              onPressed: recruiterState.isLoading
                  ? null
                  : () => onConfirmAction(
                      context,
                      ref,
                      id,
                      'Rejected',
                      updatingStatus,
                      isLoadingDialogOpen,
                    ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colorScheme.error),
                foregroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  recruiterState.isLoading &&
                      recruiterState.lastAction ==
                          RecruiterAction.updateApplicationStatus &&
                      updatingStatus.value == 'Rejected'
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Text(
                      'Reject Candidate',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Hire button
          Expanded(
            child: ElevatedButton(
              onPressed: recruiterState.isLoading
                  ? null
                  : () => onConfirmAction(
                      context,
                      ref,
                      id,
                      'Hired',
                      updatingStatus,
                      isLoadingDialogOpen,
                    ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child:
                  recruiterState.isLoading &&
                      recruiterState.lastAction ==
                          RecruiterAction.updateApplicationStatus &&
                      updatingStatus.value == 'Hired'
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
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
    );
  }
}

class _DecidedBanner extends StatelessWidget {
  const _DecidedBanner({
    required this.isHired,
    required this.updatingStatus,
    required this.application,
  });

  final bool isHired;
  final ValueNotifier<String?> updatingStatus;
  final Map<String, dynamic> application;

  @override
  Widget build(BuildContext context) {
    final color = isHired ? Colors.green : Colors.red;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isHired ? Icons.check_circle : Icons.cancel, color: color),
          const SizedBox(width: 8),
          Text(
            'Candidate already ${updatingStatus.value ?? application['status']}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
