import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/application_repository.dart';

class GetMyApplicationsUseCase {
  final ApplicationRepository _repository;

  GetMyApplicationsUseCase(this._repository);

  Future<List<ApplicationEntity>> call() {
    return _repository.getMyApplications();
  }
}
