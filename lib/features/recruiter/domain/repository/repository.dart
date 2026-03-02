import 'package:job_finder/core/helper/typedef.dart';

abstract class RecruiterRepository {
  ResultFuture<DataMap> createCompany(DataMap company);
  ResultFuture<DataMap> updateCompany(DataMap company);
  ResultFuture<DataMap> getCompanyProfile();
  ResultFuture<DataMap> createJob(DataMap job);
  ResultFuture<DataMap> submitJob(String jobId);
  ResultFuture<DataMap> getJobs({String? status});
  ResultFuture<DataMap> updateJobStatus(String jobId, String status);
  ResultFuture<DataMap> updateJob(String jobId, DataMap job);
  ResultFuture<DataMap> deleteJob(String jobId);
  ResultFuture<DataMap> getJobApplications(String jobId);
  ResultFuture<DataMap> getAllApplications();
  ResultFuture<DataMap> getApplicationDetails(String id);
  ResultFuture<DataMap> updateApplicationStatus(String id, String status);
  ResultFuture<DataMap> getRecruiterDashboard();
  ResultFuture<DataMap> getConversations();
  ResultFuture<DataMap> updateConversation(String id, DataMap body);
}
