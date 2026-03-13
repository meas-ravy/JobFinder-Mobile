import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/jobs/recruiter_jobs_state.dart';

class RecruiterJobsController extends StateNotifier<RecruiterJobsState> {
  RecruiterJobsController({
    required CreateJobUseCase createJobUseCase,
    required SubmitJobUseCase submitJobUseCase,
    required GetJobsUseCase getJobsUseCase,
    required UpdateJobStatusUseCase updateJobStatusUseCase,
    required UpdateJobUseCase updateJobUseCase,
    required DeleteJobUseCase deleteJobUseCase,
  }) : _createJobUseCase = createJobUseCase,
       _submitJobUseCase = submitJobUseCase,
       _getJobsUseCase = getJobsUseCase,
       _updateJobStatusUseCase = updateJobStatusUseCase,
       _updateJobUseCase = updateJobUseCase,
       _deleteJobUseCase = deleteJobUseCase,
       super(const RecruiterJobsState()) {
    _loadInitialData();
  }

  final CreateJobUseCase _createJobUseCase;
  final SubmitJobUseCase _submitJobUseCase;
  final GetJobsUseCase _getJobsUseCase;
  final UpdateJobStatusUseCase _updateJobStatusUseCase;
  final UpdateJobUseCase _updateJobUseCase;
  final DeleteJobUseCase _deleteJobUseCase;

  int _pendingInitialLoads = 0;

  Future<void> _loadInitialData() async {
    _pendingInitialLoads = 5;
    state = state.copyWith(isLoading: true);

    await Future.wait([
      _loadJobs(status: 'Active'),
      _loadJobs(status: 'Draft'),
      _loadJobs(status: 'Paused'),
      _loadJobs(status: 'Rejected'),
      _loadJobs(status: 'Closed'),
    ]);
  }

  void _decrementInitialLoads() {
    _pendingInitialLoads--;
    if (_pendingInitialLoads <= 0) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _loadJobs({String? status}) async {
    final result = await _getJobsUseCase(GetJobsParams(status: status));
    result.fold((failure) {}, (data) {
      final List<dynamic> jobsList =
          data['jobs'] ?? data['data']?['jobs'] ?? data['data'] ?? [];
      _updateJobsListByStatus(status, jobsList);
    });
    _decrementInitialLoads();
  }

  void _updateJobsListByStatus(String? status, List<dynamic> jobsList) {
    if (status == 'Draft') {
      state = state.copyWith(draftJobs: jobsList);
    } else if (status == 'Paused') {
      state = state.copyWith(pausedJobs: jobsList);
    } else if (status == 'Rejected') {
      state = state.copyWith(rejectedJobs: jobsList);
    } else if (status == 'Closed') {
      state = state.copyWith(previousJobs: jobsList);
    } else {
      state = state.copyWith(jobs: jobsList);
    }
  }

  Future<void> getJobs({String? status}) async {
    final result = await _getJobsUseCase(GetJobsParams(status: status));
    result.fold((failure) {}, (data) {
      final List<dynamic> jobsList =
          data['jobs'] ?? data['data']?['jobs'] ?? data['data'] ?? [];
      _updateJobsListByStatus(status, jobsList);
    });
  }

  Future<void> refreshAllJobs() async {
    state = state.copyWith(isRefreshing: true);
    await Future.wait([
      getJobs(status: 'Active'),
      getJobs(status: 'Draft'),
      getJobs(status: 'Paused'),
      getJobs(status: 'Rejected'),
      getJobs(status: 'Closed'),
    ]);
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> createJob(DataMap job) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _createJobUseCase(CreateJobParams(job: job));
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false);
        refreshAllJobs();
      },
    );
  }

  Future<void> submitJob(String jobId) async {
    state = state.copyWith(errorMessage: null, activeJobId: jobId);
    final result = await _submitJobUseCase(SubmitJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (_) {
        state = state.copyWith(activeJobId: null);
        refreshAllJobs();
      },
    );
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    state = state.copyWith(errorMessage: null, activeJobId: jobId);
    final result = await _updateJobStatusUseCase(
      UpdateJobStatusParams(jobId: jobId, status: status),
    );
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (_) {
        state = state.copyWith(activeJobId: null);
        refreshAllJobs();
      },
    );
  }

  Future<void> updateJob(String jobId, DataMap job) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _updateJobUseCase(
      UpdateJobParams(jobId: jobId, job: job),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false);
        refreshAllJobs();
      },
    );
  }

  Future<void> deleteJob(String jobId) async {
    state = state.copyWith(errorMessage: null, activeJobId: jobId);
    final result = await _deleteJobUseCase(DeleteJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (_) {
        state = state.copyWith(activeJobId: null);
        refreshAllJobs();
      },
    );
  }
}
