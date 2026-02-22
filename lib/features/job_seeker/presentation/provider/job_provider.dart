import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/job_repository_impl.dart';
import 'package:job_finder/features/job_seeker/data/server/job_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/job_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_state.dart';

final jobServerProvider = Provider<JobServer>((ref) {
  return JobServerImpl();
});

final jobRepositoryProvider = Provider((ref) {
  return JobRepositoryImpl(ref.watch(jobServerProvider));
});

final getRecommendedJobsUseCaseProvider = Provider((ref) {
  return GetRecommendedJobsUseCase(ref.watch(jobRepositoryProvider));
});

final getRecentJobsUseCaseProvider = Provider((ref) {
  return GetRecentJobsUseCase(ref.watch(jobRepositoryProvider));
});

final getJobByIdUseCaseProvider = Provider((ref) {
  return GetJobByIdUseCase(ref.watch(jobRepositoryProvider));
});

final saveJobUseCaseProvider = Provider((ref) {
  return SaveJobUseCase(ref.watch(jobRepositoryProvider));
});

final getSavedJobsUseCaseProvider = Provider((ref) {
  return GetSavedJobsUseCase(ref.watch(jobRepositoryProvider));
});

final applyJobUseCaseProvider = Provider((ref) {
  return ApplyJobUseCase(ref.watch(jobRepositoryProvider));
});

final jobDetailProvider = FutureProvider.family<JobEntity, String>((ref, id) {
  return ref.watch(getJobByIdUseCaseProvider).call(id);
});

final savedJobsProvider = FutureProvider<List<JobEntity>>((ref) {
  return ref.watch(getSavedJobsUseCaseProvider).call();
});

final jobLocalSaveStatusProvider = StateProvider.family<bool?, String>(
  (ref, id) => null,
);

final jobSavedStatusProvider = Provider.family<bool?, String>((ref, id) {
  // 1. Check local override
  final override = ref.watch(jobLocalSaveStatusProvider(id));
  if (override != null) return override;

  // 2. Cross-reference with the global saved jobs list
  final savedJobsAsync = ref.watch(savedJobsProvider);
  return savedJobsAsync.maybeWhen(
    data: (jobs) => jobs.any((j) => j.id == id),
    orElse: () => null, // Return null to fall back to the job object's isSaved
  );
});

final jobControllerProvider = StateNotifierProvider<JobController, JobState>((
  ref,
) {
  final controller = JobController(
    getRecommendedJobsUseCase: ref.watch(getRecommendedJobsUseCaseProvider),
    getRecentJobsUseCase: ref.watch(getRecentJobsUseCaseProvider),
    getSavedJobsUseCase: ref.watch(getSavedJobsUseCaseProvider),
  );
  // Fetch initial data
  Future.microtask(() => controller.fetchAll());
  return controller;
});

final mainWrapperIndexProvider = StateProvider<int>((ref) => 0);
