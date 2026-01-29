import 'package:job_finder/features/job_seeker/data/data_source/object_box.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/cv_repository.dart';
import 'package:job_finder/objectbox.g.dart';

class CvRepositoryImpl implements CvRepository {
  final ObjectBox _objectBox;

  CvRepositoryImpl(this._objectBox);

  Box<CvEntity> get _box => _objectBox.store.box<CvEntity>();

  @override
  Future<int> saveCv(CvEntity cv) async {
    return _box.put(cv);
  }

  @override
  Future<List<CvEntity>> getAllCvs() async {
    return _box.getAll();
  }

  @override
  Future<CvEntity?> getCvById(int id) async {
    return _box.get(id);
  }

  @override
  Future<bool> deleteCv(int id) async {
    return _box.remove(id);
  }
}
