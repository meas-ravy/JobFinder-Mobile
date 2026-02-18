import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/tip_repository.dart';

class GetTipsUseCase {
  final TipRepository _repository;

  GetTipsUseCase(this._repository);

  Future<List<TipEntity>> call() {
    return _repository.getTips();
  }
}

class GetTipDetailUseCase {
  final TipRepository _repository;

  GetTipDetailUseCase(this._repository);

  Future<TipEntity> call(String id) {
    return _repository.getTipDetail(id);
  }
}
