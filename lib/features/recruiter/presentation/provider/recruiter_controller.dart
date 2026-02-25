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
    required GetAllApplicationsUseCase getAllApplicationsUseCase,
    required GetApplicationDetailsUseCase getApplicationDetailsUseCase,
    required UpdateApplicationStatusUseCase updateApplicationStatusUseCase,
    required GetRecruiterDashboardUseCase getRecruiterDashboardUseCase,
    required GetConversationsUseCase getConversationsUseCase,
    required UpdateConversationUseCase updateConversationUseCase,
    required GetAgoraTokenUseCase getAgoraTokenUseCase,
    required SignalCallUseCase signalCallUseCase,
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
       _getAllApplicationsUseCase = getAllApplicationsUseCase,
       _getApplicationDetailsUseCase = getApplicationDetailsUseCase,
       _updateApplicationStatusUseCase = updateApplicationStatusUseCase,
       _getRecruiterDashboardUseCase = getRecruiterDashboardUseCase,
       _getConversationsUseCase = getConversationsUseCase,
       _updateConversationUseCase = updateConversationUseCase,
       _getAgoraTokenUseCase = getAgoraTokenUseCase,
       _signalCallUseCase = signalCallUseCase,
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
  final GetAllApplicationsUseCase _getAllApplicationsUseCase;
  final GetApplicationDetailsUseCase _getApplicationDetailsUseCase;
  final UpdateApplicationStatusUseCase _updateApplicationStatusUseCase;
  final GetRecruiterDashboardUseCase _getRecruiterDashboardUseCase;
  final GetConversationsUseCase _getConversationsUseCase;
  final UpdateConversationUseCase _updateConversationUseCase;
  final GetAgoraTokenUseCase _getAgoraTokenUseCase;
  final SignalCallUseCase _signalCallUseCase;

  CompanyModel? _parseCompany(DataMap data) {
    // 1. Check if the top level has company-like fields
    if (data.containsKey('name') && data.containsKey('contactEmail')) {
      return CompanyModel.fromJson(data);
    }

    // 2. Check for 'company' key (from some API responses)
    if (data['company'] is Map<String, dynamic>) {
      return CompanyModel.fromJson(data['company'] as Map<String, dynamic>);
    }

    // 3. Check for 'data' key (standard project wrapper)
    if (data['data'] is Map<String, dynamic>) {
      final innerData = data['data'] as Map<String, dynamic>;

      // Check if 'company' is inside 'data'
      if (innerData['company'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(
          innerData['company'] as Map<String, dynamic>,
        );
      }

      // Check if 'data' is the company itself
      if (innerData.containsKey('name')) {
        return CompanyModel.fromJson(innerData);
      }
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
        refreshAllJobs();
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
        refreshAllJobs();
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

  Future<void> refreshAllJobs() async {
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
        refreshAllJobs();
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
        refreshAllJobs();
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
        refreshAllJobs();
      },
    );
  }

  void clearApplicants() {
    state = state.copyWith(applicants: []);
  }

  Future<void> getJobApplications(String jobId, {bool refresh = false}) async {
    if (!refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastAction: RecruiterAction.getJobApplications,
      );
    }
    final result = await _getJobApplicationsUseCase(jobId);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> applicants = _parseApplicants(data);
        state = state.copyWith(
          isLoading: false,
          data: data,
          applicants: applicants,
        );
      },
    );
  }

  List<dynamic> _parseApplicants(DataMap data) {
    return data['applicants'] ??
        data['applications'] ??
        data['data']?['applicants'] ??
        data['data']?['applications'] ??
        data['data'] ??
        [];
  }

  Future<void> getAllApplications({bool refresh = false}) async {
    if (!refresh) {
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastAction: RecruiterAction.getAllApplications,
      );
    }
    final result = await _getAllApplicationsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> applicants = _parseApplicants(data);
        state = state.copyWith(
          isLoading: false,
          data: data,
          applicants: applicants,
        );
      },
    );
  }

  Future<void> getApplicationDetails(String id, {bool refresh = false}) async {
    state = state.copyWith(
      isLoading: !refresh,
      errorMessage: null,
      lastAction: RecruiterAction.getApplicationDetails,
      applicationDetails: refresh ? state.applicationDetails : null,
    );
    final result = await _getApplicationDetailsUseCase(id);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final application = data['application'] ?? data['data'] ?? data;
        DataMap? typedApplication;
        if (application is Map) {
          typedApplication = Map<String, dynamic>.from(application);
        }

        state = state.copyWith(
          isLoading: false,
          applicationDetails: typedApplication,
          data: data,
        );
      },
    );
  }

  Future<void> updateApplicationStatus(String id, String status) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.updateApplicationStatus,
    );
    final result = await _updateApplicationStatusUseCase(
      UpdateApplicationStatusParams(id, status),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final application = data['application'] ?? data['data'] ?? data;
        DataMap? typedApplication;
        if (application is Map) {
          typedApplication = Map<String, dynamic>.from(application);
        }

        state = state.copyWith(
          isLoading: false,
          data: data,
          applicationDetails: typedApplication ?? state.applicationDetails,
        );
        // Refresh anyway to be safe, but now state is updated immediately
        getApplicationDetails(id, refresh: true);
      },
    );
  }

  Future<void> getRecruiterDashboard() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getRecruiterDashboard,
    );
    final result = await _getRecruiterDashboardUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, dashboardData: data);
      },
    );
  }

  Future<void> getConversations() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getConversations,
    );
    final result = await _getConversationsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> conversations =
            data['conversations'] ?? data['data'] ?? [];
        state = state.copyWith(
          isLoading: false,
          conversations: conversations,
          data: data,
        );
      },
    );
  }

  Future<void> updateConversation(String id, DataMap body) async {
    state = state.copyWith(lastAction: RecruiterAction.updateConversation);
    final result = await _updateConversationUseCase(
      UpdateConversationParams(id: id, body: body),
    );
    result.fold(
      (failure) {
        // Silent update failure
      },
      (data) {
        // Conversation updated on server
      },
    );
  }

  Future<void> getAgoraToken(String channelName) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getAgoraToken,
    );
    final result = await _getAgoraTokenUseCase(channelName);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final token = data['token'] ?? data['data']?['token'];
        final appId = data['appId'] ?? data['data']?['appId'];
        final uid = data['uid'] ?? data['data']?['uid'];
        state = state.copyWith(
          isLoading: false,
          agoraToken: token,
          agoraAppId: appId,
          agoraUid: uid?.toString(),
          data: data,
        );
      },
    );
  }

  Future<void> signalCall(DataMap body) async {
    state = state.copyWith(lastAction: RecruiterAction.signalCall);
    final result = await _signalCallUseCase(body);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (data) {
        // Call signaled
      },
    );
  }
}
