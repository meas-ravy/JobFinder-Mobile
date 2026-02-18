import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class JobState {
  final bool isLoading;
  final bool isRecentLoading;
  final List<JobEntity> recommendedJobs;
  final List<JobEntity> recentJobs;
  final String? errorMessage;

  JobState({
    this.isLoading = false,
    this.isRecentLoading = false,
    this.recommendedJobs = const [],
    this.recentJobs = const [],
    this.errorMessage,
  });

  JobState copyWith({
    bool? isLoading,
    bool? isRecentLoading,
    List<JobEntity>? recommendedJobs,
    List<JobEntity>? recentJobs,
    String? errorMessage,
  }) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      isRecentLoading: isRecentLoading ?? this.isRecentLoading,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      recentJobs: recentJobs ?? this.recentJobs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
