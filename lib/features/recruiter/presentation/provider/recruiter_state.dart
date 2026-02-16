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
  });

  final bool isLoading;
  final String? errorMessage;
  final DataMap? data;
  final RecruiterAction? lastAction;
  final String? activeJobId;
  final CompanyModel? company;
  final List<dynamic> jobs;
  final List<dynamic> draftJobs;

  RecruiterState copyWith({
    bool? isLoading,
    String? errorMessage,
    DataMap? data,
    RecruiterAction? lastAction,
    String? activeJobId,
    CompanyModel? company,
    List<dynamic>? jobs,
    List<dynamic>? draftJobs,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      lastAction: lastAction ?? this.lastAction,
      activeJobId: activeJobId ?? this.activeJobId,
      company: company ?? this.company,
      jobs: jobs ?? this.jobs,
      draftJobs: draftJobs ?? this.draftJobs,
    );
  }
}
