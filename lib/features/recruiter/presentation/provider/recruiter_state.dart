import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';

enum RecruiterAction {
  createCompany,
  getCompanyProfile,
  updateCompany,
  createJob,
  submitJob,
  getJobs,
  updateJobStatus,
  updateJob,
  deleteJob,
  getJobApplications,
}

class RecruiterState {
  const RecruiterState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastAction,
    this.activeJobId,
    this.company,
    this.jobs = const [],
    this.draftJobs = const [],
    this.pausedJobs = const [],
    this.rejectedJobs = const [],
    this.previousJobs = const [],
    this.applicants = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final DataMap? data;
  final RecruiterAction? lastAction;
  final String? activeJobId;
  final CompanyModel? company;
  final List<dynamic> jobs;
  final List<dynamic> draftJobs;
  final List<dynamic> pausedJobs;
  final List<dynamic> rejectedJobs;
  final List<dynamic> previousJobs;
  final List<dynamic> applicants;

  static const _sentinel = Object();

  RecruiterState copyWith({
    bool? isLoading,
    String? errorMessage,
    DataMap? data,
    RecruiterAction? lastAction,
    Object? activeJobId = _sentinel,
    CompanyModel? company,
    List<dynamic>? jobs,
    List<dynamic>? draftJobs,
    List<dynamic>? pausedJobs,
    List<dynamic>? rejectedJobs,
    List<dynamic>? previousJobs,
    List<dynamic>? applicants,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      lastAction: lastAction ?? this.lastAction,
      activeJobId: activeJobId == _sentinel
          ? this.activeJobId
          : activeJobId as String?,
      company: company ?? this.company,
      jobs: jobs ?? this.jobs,
      draftJobs: draftJobs ?? this.draftJobs,
      pausedJobs: pausedJobs ?? this.pausedJobs,
      rejectedJobs: rejectedJobs ?? this.rejectedJobs,
      previousJobs: previousJobs ?? this.previousJobs,
      applicants: applicants ?? this.applicants,
    );
  }
}
