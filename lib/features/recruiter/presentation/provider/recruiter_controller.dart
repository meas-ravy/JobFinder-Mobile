import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';

class RecruiterController extends StateNotifier<RecruiterState> {
  RecruiterController({
    required CreateCompanyUseCase createCompanyUseCase,
    required GetCompanyProfileUseCase getCompanyProfileUseCase,
    required UpdateCompanyUseCase updateCompanyUseCase,
    required CreateJobUseCase createJobUseCase,
    required SubmitJobUseCase submitJobUseCase,
    required GetJobsUseCase getJobsUseCase,
    required UpdateJobStatusUseCase updateJobStatusUseCase,
    required UpdateJobUseCase updateJobUseCase,
    required DeleteJobUseCase deleteJobUseCase,
    required GetJobApplicationsUseCase getJobApplicationsUseCase,
  }) : _createCompanyUseCase = createCompanyUseCase,
       _getCompanyProfileUseCase = getCompanyProfileUseCase,
       _updateCompanyUseCase = updateCompanyUseCase,
       _createJobUseCase = createJobUseCase,
       _submitJobUseCase = submitJobUseCase,
       _getJobsUseCase = getJobsUseCase,
       _updateJobStatusUseCase = updateJobStatusUseCase,
       _updateJobUseCase = updateJobUseCase,
       _deleteJobUseCase = deleteJobUseCase,
       _getJobApplicationsUseCase = getJobApplicationsUseCase,
       super(const RecruiterState()) {
    _loadInitialData();
  }

  int _pendingInitialLoads = 0;

  Future<void> _loadInitialData() async {
    _pendingInitialLoads = 6; // company + 5 job statuses
    state = state.copyWith(isLoading: true);

    // Fire all requests concurrently, each one decrements the counter
    await Future.wait([
      _loadCompanyProfile(),
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

  Future<void> _loadCompanyProfile() async {
    final result = await _getCompanyProfileUseCase();
    result.fold(
      (failure) {
        // Don't overwrite other state on failure
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(data: data, company: parsed);
      },
    );
    _decrementInitialLoads();
  }

  Future<void> _loadJobs({String? status}) async {
    final result = await _getJobsUseCase(GetJobsParams(status: status));
    result.fold(
      (failure) {
        // Don't overwrite isLoading on failure during initial load
      },
      (data) {
        final List<dynamic> jobsList =
            data['jobs'] ?? data['data']?['jobs'] ?? data['data'] ?? [];
        _updateJobsListByStatus(status, jobsList, data);
      },
    );
    _decrementInitialLoads();
  }

  void _updateJobsListByStatus(
    String? status,
    List<dynamic> jobsList,
    DataMap data,
  ) {
    if (status == 'Draft') {
      state = state.copyWith(data: data, draftJobs: jobsList);
    } else if (status == 'Paused') {
      state = state.copyWith(data: data, pausedJobs: jobsList);
    } else if (status == 'Rejected') {
      state = state.copyWith(data: data, rejectedJobs: jobsList);
    } else if (status == 'Closed') {
      state = state.copyWith(data: data, previousJobs: jobsList);
    } else {
      state = state.copyWith(data: data, jobs: jobsList);
    }
  }

  final CreateCompanyUseCase _createCompanyUseCase;
  final GetCompanyProfileUseCase _getCompanyProfileUseCase;
  final UpdateCompanyUseCase _updateCompanyUseCase;
  final CreateJobUseCase _createJobUseCase;
  final SubmitJobUseCase _submitJobUseCase;
  final GetJobsUseCase _getJobsUseCase;
  final UpdateJobStatusUseCase _updateJobStatusUseCase;
  final UpdateJobUseCase _updateJobUseCase;
  final DeleteJobUseCase _deleteJobUseCase;
  final GetJobApplicationsUseCase _getJobApplicationsUseCase;

  CompanyModel? _parseCompany(DataMap data) {
    // Check for 'company' key (from some API responses)
    if (data['company'] is Map<String, dynamic>) {
      return CompanyModel.fromJson(data['company'] as Map<String, dynamic>);
    }

    // Check for 'data' key (standard project wrapper)
    if (data['data'] is Map<String, dynamic>) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData.containsKey('name')) {
        return CompanyModel.fromJson(innerData);
      }
    }

    // Fallback: check if the top level has company-like fields
    if (data.containsKey('name') && data.containsKey('contactEmail')) {
      return CompanyModel.fromJson(data);
    }

    return null;
  }

  Future<void> createJob(DataMap job) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.createJob,
    );
    final result = await _createJobUseCase(CreateJobParams(job: job));
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
        _refreshAllJobs();
      },
    );
  }

  Future<void> submitJob(String jobId) async {
    state = state.copyWith(
      errorMessage: null,
      lastAction: RecruiterAction.submitJob,
      activeJobId: jobId,
    );
    final result = await _submitJobUseCase(SubmitJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (data) {
        state = state.copyWith(data: data, activeJobId: null);
        _refreshAllJobs();
      },
    );
  }

  Future<void> updateCompany(DataMap company) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.updateCompany,
    );
    final result = await _updateCompanyUseCase(
      UpdateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, data: data, company: parsed);
      },
    );
  }

  Future<void> createCompany(DataMap company) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.createCompany,
    );
    final result = await _createCompanyUseCase(
      CreateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, data: data, company: parsed);
      },
    );
  }

  Future<void> getCompanyProfile() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getCompanyProfile,
    );
    final result = await _getCompanyProfileUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, data: data, company: parsed);
      },
    );
  }

  Future<void> getJobs({String? status}) async {
    final result = await _getJobsUseCase(GetJobsParams(status: status));
    result.fold(
      (failure) {
        // Silent failure for background refresh
      },
      (data) {
        final List<dynamic> jobsList =
            data['jobs'] ?? data['data']?['jobs'] ?? data['data'] ?? [];
        _updateJobsListByStatus(status, jobsList, data);
      },
    );
  }

  /// Silently refresh all job tabs without flipping isLoading
  Future<void> _refreshAllJobs() async {
    await Future.wait([
      getJobs(status: 'Active'),
      getJobs(status: 'Draft'),
      getJobs(status: 'Paused'),
      getJobs(status: 'Rejected'),
      getJobs(status: 'Closed'),
    ]);
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    state = state.copyWith(
      errorMessage: null,
      lastAction: RecruiterAction.updateJobStatus,
      activeJobId: jobId,
    );
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
      (data) {
        state = state.copyWith(data: data, activeJobId: null);
        _refreshAllJobs();
      },
    );
  }

  Future<void> updateJob(String jobId, DataMap job) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.updateJob,
    );
    final result = await _updateJobUseCase(
      UpdateJobParams(jobId: jobId, job: job),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
        _refreshAllJobs();
      },
    );
  }

  Future<void> deleteJob(String jobId) async {
    state = state.copyWith(
      errorMessage: null,
      lastAction: RecruiterAction.deleteJob,
      activeJobId: jobId,
    );
    final result = await _deleteJobUseCase(DeleteJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (data) {
        state = state.copyWith(data: data, activeJobId: null);
        _refreshAllJobs();
      },
    );
  }

  Future<void> getJobApplications(String jobId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getJobApplications,
    );
    final result = await _getJobApplicationsUseCase(jobId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> applicants =
            data['applicants'] ??
            data['data']?['applicants'] ??
            data['data'] ??
            [];
        state = state.copyWith(
          isLoading: false,
          data: data,
          applicants: applicants,
        );
      },
    );
  }
}
