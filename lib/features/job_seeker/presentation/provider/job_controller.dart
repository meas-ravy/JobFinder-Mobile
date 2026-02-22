import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/job_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_state.dart';

class JobController extends StateNotifier<JobState> {
  final GetRecommendedJobsUseCase _getRecommendedJobsUseCase;
  final GetRecentJobsUseCase _getRecentJobsUseCase;
  final GetSavedJobsUseCase _getSavedJobsUseCase;

  JobController({
    required GetRecommendedJobsUseCase getRecommendedJobsUseCase,
    required GetRecentJobsUseCase getRecentJobsUseCase,
    required GetSavedJobsUseCase getSavedJobsUseCase,
  }) : _getRecommendedJobsUseCase = getRecommendedJobsUseCase,
       _getRecentJobsUseCase = getRecentJobsUseCase,
       _getSavedJobsUseCase = getSavedJobsUseCase,
       super(JobState());

  Future<void> fetchRecommendedJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final jobs = await _getRecommendedJobsUseCase();
      state = state.copyWith(isLoading: false, recommendedJobs: jobs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchRecentJobs({String? category}) async {
    state = state.copyWith(isRecentLoading: true);
    try {
      final jobs = await _getRecentJobsUseCase(category: category);
      state = state.copyWith(isRecentLoading: false, recentJobs: jobs);
    } catch (e) {
      state = state.copyWith(
        isRecentLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Fetch all required data in parallel including saved jobs
      final results = await Future.wait([
        _getRecommendedJobsUseCase(),
        _getRecentJobsUseCase(),
        _getSavedJobsUseCase(),
      ]);

      state = state.copyWith(
        isLoading: false,
        recommendedJobs: results[0],
        recentJobs: results[1],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
