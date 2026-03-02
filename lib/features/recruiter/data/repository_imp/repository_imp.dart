import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/data/server/recruiter_server.dart';
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
  ResultFuture<DataMap> getJobApplications(String jobId) {
    return _server.getJobApplications(jobId);
  }

  @override
  ResultFuture<DataMap> getAllApplications() {
    return _server.getAllApplications();
  }

  @override
  ResultFuture<DataMap> getApplicationDetails(String id) {
    return _server.getApplicationDetails(id);
  }

  @override
  ResultFuture<DataMap> updateApplicationStatus(String id, String status) {
    return _server.updateApplicationStatus(id, status);
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
