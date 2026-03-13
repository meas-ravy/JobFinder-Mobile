import 'package:job_finder/core/helper/typedef.dart';

class RecruiterDashboardState {
  const RecruiterDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.dashboardData,
  });

  final bool isLoading;
  final String? errorMessage;
  final DataMap? dashboardData;

  RecruiterDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    DataMap? dashboardData,
  }) {
    return RecruiterDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      dashboardData: dashboardData ?? this.dashboardData,
    );
  }
}
