import 'package:job_finder/features/job_seeker/data/server/tip_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/tip_repository.dart';

class TipRepositoryImpl implements TipRepository {
  final TipServer _server;

  TipRepositoryImpl(this._server);

  @override
  Future<List<TipEntity>> getTips() {
    return _server.getTips();
  }

  @override
  Future<TipEntity> getTipDetail(String id) {
    return _server.getTipDetail(id);
  }
}
