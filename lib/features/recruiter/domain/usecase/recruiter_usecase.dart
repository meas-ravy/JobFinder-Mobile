import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_detail_entity.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_entity.dart';
import 'package:job_finder/features/recruiter/domain/entity/job_entity.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';

class CreateCompanyParams {
  const CreateCompanyParams({required this.company});
  final DataMap company;
}

class CreateCompanyUseCase
    extends UseCaseWithParams<DataMap, CreateCompanyParams> {
  const CreateCompanyUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(CreateCompanyParams params) {
    return _repository.createCompany(params.company);
  }
}

class GetCompanyProfileUseCase extends UseCaseWithOutParams<DataMap> {
  const GetCompanyProfileUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call() {
    return _repository.getCompanyProfile();
  }
}

class UpdateCompanyParams {
  const UpdateCompanyParams({required this.company});
  final DataMap company;
}

class UpdateCompanyUseCase
    extends UseCaseWithParams<DataMap, UpdateCompanyParams> {
  const UpdateCompanyUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(UpdateCompanyParams params) {
    return _repository.updateCompany(params.company);
  }
}

class CreateJobParams {
  const CreateJobParams({required this.job});
  final JobEntity job;
}

class CreateJobUseCase extends UseCaseWithParams<DataMap, CreateJobParams> {
  const CreateJobUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(CreateJobParams params) {
    return _repository.createJob(params.job);
  }
}

class SubmitJobParams {
  const SubmitJobParams({required this.jobId});
  final String jobId;
}

class SubmitJobUseCase extends UseCaseWithParams<DataMap, SubmitJobParams> {
  const SubmitJobUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(SubmitJobParams params) {
    return _repository.submitJob(params.jobId);
  }
}

class GetJobsParams {
  const GetJobsParams({this.status});
  final String? status;
}

class GetJobsUseCase extends UseCaseWithParams<DataMap, GetJobsParams> {
  const GetJobsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(GetJobsParams params) {
    return _repository.getJobs(status: params.status);
  }
}

class UpdateJobStatusParams {
  const UpdateJobStatusParams({required this.jobId, required this.status});
  final String jobId;
  final String status;
}

class UpdateJobStatusUseCase
    extends UseCaseWithParams<DataMap, UpdateJobStatusParams> {
  const UpdateJobStatusUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(UpdateJobStatusParams params) {
    return _repository.updateJobStatus(params.jobId, params.status);
  }
}

class UpdateJobParams {
  const UpdateJobParams({required this.jobId, required this.job});
  final String jobId;
  final JobEntity job;
}

class UpdateJobUseCase extends UseCaseWithParams<DataMap, UpdateJobParams> {
  const UpdateJobUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(UpdateJobParams params) {
    return _repository.updateJob(params.jobId, params.job);
  }
}

class DeleteJobParams {
  const DeleteJobParams({required this.jobId});
  final String jobId;
}

class DeleteJobUseCase extends UseCaseWithParams<DataMap, DeleteJobParams> {
  const DeleteJobUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(DeleteJobParams params) {
    return _repository.deleteJob(params.jobId);
  }
}

class GetJobApplicationsUseCase extends UseCaseWithParams<List<ApplicationEntity>, String> {
  const GetJobApplicationsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<List<ApplicationEntity>> call(String params) {
    return _repository.getJobApplications(params);
  }
}

class GetAllApplicationsUseCase extends UseCaseWithOutParams<List<ApplicationEntity>> {
  const GetAllApplicationsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<List<ApplicationEntity>> call() {
    return _repository.getAllApplications();
  }
}

class GetApplicationDetailsUseCase extends UseCaseWithParams<ApplicationDetailEntity, String> {
  const GetApplicationDetailsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<ApplicationDetailEntity> call(String params) {
    return _repository.getApplicationDetails(params);
  }
}

class UpdateApplicationStatusParams {
  const UpdateApplicationStatusParams(this.id, this.status);
  final String id;
  final String status;
}

class UpdateApplicationStatusUseCase
    extends UseCaseWithParams<ApplicationDetailEntity, UpdateApplicationStatusParams> {
  const UpdateApplicationStatusUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<ApplicationDetailEntity> call(UpdateApplicationStatusParams params) {
    return _repository.updateApplicationStatus(params.id, params.status);
  }
}

class GetRecruiterDashboardUseCase extends UseCaseWithOutParams<DataMap> {
  const GetRecruiterDashboardUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call() {
    return _repository.getRecruiterDashboard();
  }
}

class GetConversationsUseCase extends UseCaseWithOutParams<DataMap> {
  const GetConversationsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call() {
    return _repository.getConversations();
  }
}

class UpdateConversationParams {
  const UpdateConversationParams({required this.id, required this.body});
  final String id;
  final DataMap body;
}

class UpdateConversationUseCase
    extends UseCaseWithParams<DataMap, UpdateConversationParams> {
  const UpdateConversationUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(UpdateConversationParams params) {
    return _repository.updateConversation(params.id, params.body);
  }
}
