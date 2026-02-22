import 'package:job_finder/features/job_seeker/data/server/application_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/application_repository.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationServer _server;

  ApplicationRepositoryImpl(this._server);

  @override
  Future<List<ApplicationEntity>> getMyApplications() {
    return _server.getMyApplications();
  }
}
