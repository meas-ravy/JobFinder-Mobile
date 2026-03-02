import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class SavedJobState {
  final bool isLoading;
  final List<JobEntity> savedJobs;
  final String? errorMessage;
  // Track which job IDs are currently being toggled (for showing spinners on individual cards)
  final Set<String> togglingJobIds;

  SavedJobState({
    this.isLoading = false,
    this.savedJobs = const [],
    this.errorMessage,
    this.togglingJobIds = const {},
  });

  // Check if a specific job is saved
  bool isJobSaved(String jobId) {
    return savedJobs.any((job) => job.id == jobId);
  }

  SavedJobState copyWith({
    bool? isLoading,
    List<JobEntity>? savedJobs,
    String? errorMessage,
    Set<String>? togglingJobIds,
  }) {
    return SavedJobState(
      isLoading: isLoading ?? this.isLoading,
      savedJobs: savedJobs ?? this.savedJobs,
      errorMessage: errorMessage ?? this.errorMessage,
      togglingJobIds: togglingJobIds ?? this.togglingJobIds,
    );
  }
}
