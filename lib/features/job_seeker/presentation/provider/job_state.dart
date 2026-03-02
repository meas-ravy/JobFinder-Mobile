import 'package:job_finder/core/helper/pagination.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class JobState {
  final bool isLoading;
  final bool isRecentLoading;
  final bool isFetchingMore;
  final List<JobEntity> recommendedJobs;
  final List<JobEntity> recentJobs;
  final String? errorMessage;
  final PaginationInfo? pagination;

  JobState({
    this.isLoading = false,
    this.isRecentLoading = false,
    this.isFetchingMore = false,
    this.recommendedJobs = const [],
    this.recentJobs = const [],
    this.errorMessage,
    this.pagination,
  });

  JobState copyWith({
    bool? isLoading,
    bool? isRecentLoading,
    bool? isFetchingMore,
    List<JobEntity>? recommendedJobs,
    List<JobEntity>? recentJobs,
    String? errorMessage,
    PaginationInfo? pagination,
  }) {
    return JobState(
      isLoading: isLoading ?? this.isLoading,
      isRecentLoading: isRecentLoading ?? this.isRecentLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      recentJobs: recentJobs ?? this.recentJobs,
      errorMessage: errorMessage ?? this.errorMessage,
      pagination: pagination ?? this.pagination,
    );
  }
}
