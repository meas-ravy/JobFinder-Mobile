import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';

abstract class TipRepository {
  Future<List<TipEntity>> getTips();
  Future<TipEntity> getTipDetail(String id);
}
