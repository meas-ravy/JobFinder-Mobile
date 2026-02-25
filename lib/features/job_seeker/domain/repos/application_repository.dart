import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';

abstract class ApplicationRepository {
  Future<List<ApplicationEntity>> getMyApplications();
  Future<ApplicationEntity> getApplicationDetails(String id);
}
