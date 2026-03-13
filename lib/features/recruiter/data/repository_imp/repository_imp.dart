import 'package:dartz/dartz.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/application_detail_model.dart';
import 'package:job_finder/features/recruiter/data/models/application_model.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/data/server/recruiter_server.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_detail_entity.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_entity.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';

class RecruiterRepositoryImpl implements RecruiterRepository {
  const RecruiterRepositoryImpl(this._server);

  final RecruiterServer _server;

  @override
  ResultFuture<DataMap> createCompany(DataMap company) {
    return _server.createCompany(CompanyModel.fromJson(company));
  }

  @override
  ResultFuture<DataMap> updateCompany(DataMap company) {
    return _server.updateCompany(company);
  }

  @override
  ResultFuture<DataMap> getCompanyProfile() {
    return _server.getCompanyProfile();
  }

  @override
  ResultFuture<DataMap> createJob(DataMap job) {
    return _server.createJob(job);
  }

  @override
  ResultFuture<DataMap> submitJob(String jobId) {
    return _server.submitJob(jobId);
  }

  @override
  ResultFuture<DataMap> getJobs({String? status}) {
    return _server.getJobs(status: status);
  }

  @override
  ResultFuture<DataMap> updateJobStatus(String jobId, String status) {
    return _server.updateJobStatus(jobId, status);
  }

  @override
  ResultFuture<DataMap> updateJob(String jobId, DataMap job) {
    return _server.updateJob(jobId, job);
  }

  @override
  ResultFuture<DataMap> deleteJob(String jobId) {
    return _server.deleteJob(jobId);
  }

  @override
  ResultFuture<List<ApplicationEntity>> getJobApplications(String jobId) async {
    final result = await _server.getJobApplications(jobId);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        final List<dynamic> list = data['applicants'] ??
            data['applications'] ??
            data['data']?['applicants'] ??
            data['data']?['applications'] ??
            data['data'] ??
            [];
        final applications = list
            .map((e) => ApplicationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(applications);
      },
    );
  }

  @override
  ResultFuture<List<ApplicationEntity>> getAllApplications() async {
    final result = await _server.getAllApplications();
    return result.fold(
      (failure) => Left(failure),
      (data) {
        final List<dynamic> list = data['applicants'] ??
            data['applications'] ??
            data['data']?['applicants'] ??
            data['data']?['applications'] ??
            data['data'] ??
            [];
        final applications = list
            .map((e) => ApplicationModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        return Right(applications);
      },
    );
  }

  @override
  ResultFuture<ApplicationDetailEntity> getApplicationDetails(String id) async {
    final result = await _server.getApplicationDetails(id);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        final application = data['application'] ?? data['data'] ?? data;
        return Right(
          ApplicationDetailModel.fromJson(Map<String, dynamic>.from(application)),
        );
      },
    );
  }

  @override
  ResultFuture<ApplicationDetailEntity> updateApplicationStatus(
    String id,
    String status,
  ) async {
    final result = await _server.updateApplicationStatus(id, status);
    return result.fold(
      (failure) => Left(failure),
      (data) {
        final application = data['application'] ?? data['data'] ?? data;
        return Right(
          ApplicationDetailModel.fromJson(Map<String, dynamic>.from(application)),
        );
      },
    );
  }

  @override
  ResultFuture<DataMap> getRecruiterDashboard() {
    return _server.getRecruiterDashboard();
  }

  @override
  ResultFuture<DataMap> getConversations() {
    return _server.getConversations();
  }

  @override
  ResultFuture<DataMap> updateConversation(String id, DataMap body) {
    return _server.updateConversation(id, body);
  }
}
