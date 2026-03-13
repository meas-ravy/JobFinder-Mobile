import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/applications/recruiter_applications_state.dart';

class RecruiterApplicationsController
    extends StateNotifier<RecruiterApplicationsState> {
  RecruiterApplicationsController({
    required GetJobApplicationsUseCase getJobApplicationsUseCase,
    required GetAllApplicationsUseCase getAllApplicationsUseCase,
    required GetApplicationDetailsUseCase getApplicationDetailsUseCase,
    required UpdateApplicationStatusUseCase updateApplicationStatusUseCase,
  }) : _getJobApplicationsUseCase = getJobApplicationsUseCase,
       _getAllApplicationsUseCase = getAllApplicationsUseCase,
       _getApplicationDetailsUseCase = getApplicationDetailsUseCase,
       _updateApplicationStatusUseCase = updateApplicationStatusUseCase,
       super(const RecruiterApplicationsState());

  final GetJobApplicationsUseCase _getJobApplicationsUseCase;
  final GetAllApplicationsUseCase _getAllApplicationsUseCase;
  final GetApplicationDetailsUseCase _getApplicationDetailsUseCase;
  final UpdateApplicationStatusUseCase _updateApplicationStatusUseCase;

  void clearApplicants() {
    state = state.copyWith(applicants: []);
  }

  void clearApplicationDetails() {
    state = state.copyWith(applicationDetails: null);
  }

  Future<void> getJobApplications(String jobId, {bool refresh = false}) async {
    if (!refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final result = await _getJobApplicationsUseCase(jobId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (applicants) {
        state = state.copyWith(isLoading: false, applicants: applicants);
      },
    );
  }

  Future<void> getAllApplications({bool refresh = false}) async {
    if (!refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final result = await _getAllApplicationsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (applicants) {
        state = state.copyWith(isLoading: false, applicants: applicants);
      },
    );
  }

  Future<void> getApplicationDetails(String id, {bool refresh = false}) async {
    state = state.copyWith(
      isLoading: !refresh,
      errorMessage: null,
      applicationDetails: refresh ? state.applicationDetails : null,
    );
    final result = await _getApplicationDetailsUseCase(id);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (application) {
        state = state.copyWith(
          isLoading: false,
          applicationDetails: application,
        );
      },
    );
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _updateApplicationStatusUseCase(
      UpdateApplicationStatusParams(id, status),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (application) {
        state = state.copyWith(
          isLoading: false,
          applicationDetails: application,
        );
        // Refresh to guarantee sub-fields like timelines are synced
        getApplicationDetails(id, refresh: true);
      },
    );
  }
}
