import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

abstract class CvRepository {
  Future<int> saveCv(CvEntity cv);
  Future<List<CvEntity>> getAllCvs();
  Future<CvEntity?> getCvById(int id);
  Future<bool> deleteCv(int id);
}
