import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/application_repository_impl.dart';
import 'package:job_finder/features/job_seeker/data/server/application_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/application_usecase.dart';

final applicationServerProvider = Provider<ApplicationServer>((ref) {
  return ApplicationServerImpl();
});

final applicationRepositoryProvider = Provider((ref) {
  return ApplicationRepositoryImpl(ref.watch(applicationServerProvider));
});

final getMyApplicationsUseCaseProvider = Provider((ref) {
  return GetMyApplicationsUseCase(ref.watch(applicationRepositoryProvider));
});

final myApplicationsProvider = FutureProvider<List<ApplicationEntity>>((ref) {
  return ref.watch(getMyApplicationsUseCaseProvider).call();
});
