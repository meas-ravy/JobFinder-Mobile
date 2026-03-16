import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/dashboard/recruiter_dashboard_state.dart';

class RecruiterDashboardController
    extends StateNotifier<RecruiterDashboardState> {
  RecruiterDashboardController({
    required GetRecruiterDashboardUseCase getRecruiterDashboardUseCase,
  }) : _getRecruiterDashboardUseCase = getRecruiterDashboardUseCase,
       super(const RecruiterDashboardState());

  final GetRecruiterDashboardUseCase _getRecruiterDashboardUseCase;

  Future<void> getRecruiterDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getRecruiterDashboardUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isInitial: false,
          errorMessage: failure.message,
        );
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          isInitial: false,
          dashboardData: data,
        );
      },
    );
  }
}
