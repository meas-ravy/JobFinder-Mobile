import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/job_repository.dart';

class GetRecommendedJobsUseCase {
  final JobRepository _repository;

  GetRecommendedJobsUseCase(this._repository);

  Future<List<JobEntity>> call() {
    return _repository.getRecommendedJobs();
  }
}

class GetRecentJobsUseCase {
  final JobRepository _repository;

  GetRecentJobsUseCase(this._repository);

  Future<List<JobEntity>> call({String? category}) {
    return _repository.getRecentJobs(category: category);
  }
}

class GetJobByIdUseCase {
  final JobRepository _repository;

  GetJobByIdUseCase(this._repository);

  Future<JobEntity> call(String id) {
    return _repository.getJobById(id);
  }
}

class SaveJobUseCase {
  final JobRepository _repository;

  SaveJobUseCase(this._repository);

  Future<bool> call(String id) {
    return _repository.saveJob(id);
  }
}

class GetSavedJobsUseCase {
  final JobRepository _repository;

  GetSavedJobsUseCase(this._repository);

  Future<List<JobEntity>> call() {
    return _repository.getSavedJobs();
  }
}
