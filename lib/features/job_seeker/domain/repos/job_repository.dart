import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/entities/paginated_jobs.dart';

abstract class JobRepository {
  Future<List<JobEntity>> getRecommendedJobs();
  Future<PaginatedJobs> getRecentJobs({
    String? category,
    int page = 1,
    int limit = 20,
  });
  Future<JobEntity> getJobById(String id);
  Future<bool> saveJob(String id);
  Future<List<JobEntity>> getSavedJobs();
  Future<void> applyJob({
    required String jobId,
    required String fullName,
    required String email,
    required String resumeUrl,
    String? coverLetter,
  });
}
