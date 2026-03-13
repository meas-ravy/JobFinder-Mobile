import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_detail_entity.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_entity.dart';

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
  ResultFuture<List<ApplicationEntity>> getJobApplications(String jobId);
  ResultFuture<List<ApplicationEntity>> getAllApplications();
  ResultFuture<ApplicationDetailEntity> getApplicationDetails(String id);
  ResultFuture<ApplicationDetailEntity> updateApplicationStatus(String id, String status);
  ResultFuture<DataMap> getRecruiterDashboard();
  ResultFuture<DataMap> getConversations();
  ResultFuture<DataMap> updateConversation(String id, DataMap body);
}
