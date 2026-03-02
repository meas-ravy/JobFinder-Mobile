import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/job_repository_impl.dart';
import 'package:job_finder/features/job_seeker/data/server/job_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/job_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_state.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/saved_job_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/saved_job_state.dart';

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

// Job Controller
final jobControllerProvider = NotifierProvider<JobController, JobState>(
  JobController.new,
);

// Saved Job Controller
final savedJobControllerProvider =
    NotifierProvider<SavedJobController, SavedJobState>(SavedJobController.new);

// Check if a specific job is saved (reads from SavedJobController)
final jobSavedStatusProvider = Provider.family<bool, String>((ref, id) {
  final savedState = ref.watch(savedJobControllerProvider);
  return savedState.isJobSaved(id);
});

final mainWrapperIndexProvider = StateProvider<int>((ref) => 0);
