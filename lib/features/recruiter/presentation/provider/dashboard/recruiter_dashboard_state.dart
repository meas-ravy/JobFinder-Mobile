import 'package:job_finder/core/helper/typedef.dart';

class RecruiterDashboardState {
  const RecruiterDashboardState({
    this.isLoading = false,
    this.isInitial = true,
    this.errorMessage,
    this.dashboardData,
  });

  final bool isLoading;
  final bool isInitial;
  final String? errorMessage;
  final DataMap? dashboardData;

  RecruiterDashboardState copyWith({
    bool? isLoading,
    bool? isInitial,
    String? errorMessage,
    DataMap? dashboardData,
  }) {
    return RecruiterDashboardState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      errorMessage: errorMessage,
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}
