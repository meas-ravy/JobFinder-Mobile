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
    getCompanyProfile();
    getJobs(status: 'Active');
    getJobs(status: 'Draft');
    getJobs(status: 'Rejected');
    getJobs(status: 'Closed');
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
      },
    );
  }

  Future<void> submitJob(String jobId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.submitJob,
      activeJobId: jobId,
    );
    final result = await _submitJobUseCase(SubmitJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data, activeJobId: null);
        getJobs(status: 'Active');
        getJobs(status: 'Draft');
        getJobs(status: 'Rejected');
        getJobs(status: 'Closed');
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
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getJobs,
    );
    final result = await _getJobsUseCase(GetJobsParams(status: status));
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> jobsList =
            data['jobs'] ?? data['data']?['jobs'] ?? data['data'] ?? [];
        if (status == 'Draft') {
          state = state.copyWith(
            isLoading: false,
            data: data,
            draftJobs: jobsList,
          );
        } else if (status == 'Rejected') {
          state = state.copyWith(
            isLoading: false,
            data: data,
            rejectedJobs: jobsList,
          );
        } else if (status == 'Closed') {
          state = state.copyWith(
            isLoading: false,
            data: data,
            previousJobs: jobsList,
          );
        } else {
          state = state.copyWith(isLoading: false, data: data, jobs: jobsList);
        }
      },
    );
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    state = state.copyWith(
      isLoading: true,
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
          isLoading: false,
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data, activeJobId: null);
        getJobs(status: 'Active');
        getJobs(status: 'Draft');
        getJobs(status: 'Rejected');
        getJobs(status: 'Closed');
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
        getJobs(status: 'Active');
        getJobs(status: 'Draft');
        getJobs(status: 'Rejected');
        getJobs(status: 'Closed');
      },
    );
  }

  Future<void> deleteJob(String jobId) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.deleteJob,
      activeJobId: jobId,
    );
    final result = await _deleteJobUseCase(DeleteJobParams(jobId: jobId));
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          activeJobId: null,
        );
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data, activeJobId: null);
        getJobs(status: 'Active');
        getJobs(status: 'Draft');
        getJobs(status: 'Rejected');
        getJobs(status: 'Closed');
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
