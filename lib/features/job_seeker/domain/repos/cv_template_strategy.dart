import 'package:pdf/widgets.dart' as pw;
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

abstract class CvTemplateStrategy {
  Future<void> build(pw.Document pdf, CvEntity cv);
}
