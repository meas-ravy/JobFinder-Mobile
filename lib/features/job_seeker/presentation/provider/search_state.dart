import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class SearchFilters {
  final String? location;
  final double? salaryMin;
  final double? salaryMax;
  final String? workArrangement;
  final String? experienceLevel;
  final String? employmentType;
  final String? category;

  const SearchFilters({
    this.location,
    this.salaryMin,
    this.salaryMax,
    this.workArrangement,
    this.experienceLevel,
    this.employmentType,
    this.category,
  });

  SearchFilters copyWith({
    String? location,
    double? salaryMin,
    double? salaryMax,
    String? workArrangement,
    String? experienceLevel,
    String? employmentType,
    String? category,
  }) {
    return SearchFilters(
      location: location ?? this.location,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      workArrangement: workArrangement ?? this.workArrangement,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      employmentType: employmentType ?? this.employmentType,
      category: category ?? this.category,
    );
  }

  bool get hasActiveFilters =>
      location != null ||
      salaryMin != null ||
      salaryMax != null ||
      workArrangement != null ||
      experienceLevel != null ||
      employmentType != null ||
      category != null;

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (location != null && location!.isNotEmpty) params['location'] = location;
    if (salaryMin != null) params['salaryMin'] = salaryMin;
    if (salaryMax != null) params['salaryMax'] = salaryMax;
    if (workArrangement != null) params['workArrangement'] = workArrangement;
    if (experienceLevel != null) params['experienceLevel'] = experienceLevel;
    if (employmentType != null) params['employmentType'] = employmentType;
    if (category != null) params['category'] = category;
    return params;
  }
}

class SearchState {
  final bool isLoading;
  final List<JobEntity> results;
  final int totalCount;
  final String query;
  final SearchFilters filters;
  final String? errorMessage;
  final bool hasSearched;

  SearchState({
    this.isLoading = false,
    this.results = const [],
    this.totalCount = 0,
    this.query = '',
    this.filters = const SearchFilters(),
    this.errorMessage,
    this.hasSearched = false,
  });

  SearchState copyWith({
    bool? isLoading,
    List<JobEntity>? results,
    int? totalCount,
    String? query,
    SearchFilters? filters,
    String? errorMessage,
    bool? hasSearched,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      totalCount: totalCount ?? this.totalCount,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }
}
