import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/job_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_state.dart';
import 'package:job_finder/features/job_seeker/domain/entities/paginated_jobs.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';

class JobController extends Notifier<JobState> {
  GetRecommendedJobsUseCase get _getRecomJobUseCase =>
      ref.read(getRecommendedJobsUseCaseProvider);
  GetRecentJobsUseCase get _getRecentJobUseCase =>
      ref.read(getRecentJobsUseCaseProvider);
  GetSavedJobsUseCase get _getSavedJobUseCase =>
      ref.read(getSavedJobsUseCaseProvider);

  // init first state
  @override
  JobState build() {
    Future.microtask(() => fetchAll());
    return JobState();
  }

  ResultVoid fetchRecomJob() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _getRecomJobUseCase();
      state = state.copyWith(recommendedJobs: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // for get all jobs by fetch recent jobs with pagination
  ResultVoid fetchRecentJob({String? category}) async {
    state = state.copyWith(isRecentLoading: true, errorMessage: null);
    try {
      final result = await _getRecentJobUseCase(
        category: category,
        page: 1, // start with 1 page
      );
      state = state.copyWith(
        isRecentLoading: false,
        recentJobs: result.jobs,
        pagination: result.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isRecentLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  ResultVoid fetchMoreRecentJobs({String? category}) async {
    // If already loading or no more pages, return
    if (state.isFetchingMore || state.pagination?.hasMore == false) return;

    state = state.copyWith(isFetchingMore: true);
    try {
      final nextPage = (state.pagination?.page ?? 1) + 1;
      final paginatedResults = await _getRecentJobUseCase(
        category: category,
        page: nextPage,
      );

      state = state.copyWith(
        isFetchingMore: false,
        recentJobs: [...state.recentJobs, ...paginatedResults.jobs],
        pagination: paginatedResults.pagination,
      );
    } catch (e) {
      state = state.copyWith(isFetchingMore: false);
    }
  }

  ResultVoid fetchAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await Future.wait([
        _getRecomJobUseCase(),
        _getRecentJobUseCase(page: 1),
        _getSavedJobUseCase(),
      ]);

      final recommended = results[0] as List;
      final recentPaginated = results[1] as PaginatedJobs;

      state = state.copyWith(
        isLoading: false,
        recommendedJobs: List.from(recommended),
        recentJobs: recentPaginated.jobs,
        pagination: recentPaginated.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
