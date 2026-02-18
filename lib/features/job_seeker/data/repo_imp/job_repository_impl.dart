import 'package:job_finder/features/job_seeker/data/server/job_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/job_repository.dart';

class JobRepositoryImpl implements JobRepository {
  final JobServer _server;

  JobRepositoryImpl(this._server);

  @override
  Future<List<JobEntity>> getRecommendedJobs() {
    return _server.getRecommendedJobs();
  }

  @override
  Future<List<JobEntity>> getRecentJobs({String? category}) {
    return _server.getRecentJobs(category: category);
  }

  @override
  Future<JobEntity> getJobById(String id) {
    return _server.getJobById(id);
  }

  @override
  Future<bool> saveJob(String id) {
    return _server.saveJob(id);
  }

  @override
  Future<List<JobEntity>> getSavedJobs() {
    return _server.getSavedJobs();
  }
}
