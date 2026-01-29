import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/cv_repository_impl.dart';
import 'package:job_finder/features/job_seeker/domain/repos/cv_repository.dart';
import 'package:job_finder/main.dart';

final cvRepositoryProvider = Provider<CvRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return CvRepositoryImpl(objectBox);
});
