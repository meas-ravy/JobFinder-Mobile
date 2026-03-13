class RecruiterJobsState {
  const RecruiterJobsState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.errorMessage,
    this.activeJobId,
    this.jobs = const [],
    this.draftJobs = const [],
    this.pausedJobs = const [],
    this.rejectedJobs = const [],
    this.previousJobs = const [],
  });

  final bool isLoading;
  final bool isRefreshing;
  final String? errorMessage;
  final String? activeJobId;
  final List<dynamic> jobs;
  final List<dynamic> draftJobs;
  final List<dynamic> pausedJobs;
  final List<dynamic> rejectedJobs;
  final List<dynamic> previousJobs;

  RecruiterJobsState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? errorMessage,
    String? activeJobId,
    List<dynamic>? jobs,
    List<dynamic>? draftJobs,
    List<dynamic>? pausedJobs,
    List<dynamic>? rejectedJobs,
    List<dynamic>? previousJobs,
  }) {
    return RecruiterJobsState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage, // null by default, must explicitly clear
      activeJobId: activeJobId,
      jobs: jobs ?? this.jobs,
      draftJobs: draftJobs ?? this.draftJobs,
      pausedJobs: pausedJobs ?? this.pausedJobs,
      rejectedJobs: rejectedJobs ?? this.rejectedJobs,
      previousJobs: previousJobs ?? this.previousJobs,
    );
  }
}
