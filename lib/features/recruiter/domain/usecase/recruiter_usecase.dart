import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
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
  final DataMap job;
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
  final DataMap job;
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

class GetJobApplicationsUseCase extends UseCaseWithParams<DataMap, String> {
  const GetJobApplicationsUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(String params) {
    return _repository.getJobApplications(params);
  }
}
