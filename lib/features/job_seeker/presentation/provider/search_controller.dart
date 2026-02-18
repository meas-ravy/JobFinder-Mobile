import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/job_model.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/search_state.dart';

class SearchController extends StateNotifier<SearchState> {
  final _dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  SearchController() : super(SearchState());

  Future<void> searchJobs(String query, {SearchFilters? filters}) async {
    if (query.trim().isEmpty &&
        (filters == null || !filters.hasActiveFilters)) {
      state = SearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      query: query,
      filters: filters ?? state.filters,
      hasSearched: true,
      errorMessage: null,
    );

    try {
      final queryParams = <String, dynamic>{
        'section': 'search',
        if (query.trim().isNotEmpty) 'search': query.trim(),
        ...(filters ?? state.filters).toQueryParams(),
      };

      final response = await _dio.get(
        ApiEnpoint.jobs,
        queryParameters: queryParams,
      );

      final List<dynamic> jobsJson = response.data['jobs'] ?? [];
      final jobs = jobsJson.map((json) => JobModel.fromJson(json)).toList();
      final totalCount =
          response.data['pagination']?['totalCount'] ?? jobs.length;

      state = state.copyWith(
        isLoading: false,
        results: jobs,
        totalCount: totalCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        results: [],
        totalCount: 0,
      );
    }
  }

  void updateFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  void clearSearch() {
    state = SearchState();
  }

  void applyFilters(SearchFilters filters) {
    searchJobs(state.query, filters: filters);
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
      return SearchController();
    });
