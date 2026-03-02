import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/job_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/job_provider.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/saved_job_state.dart';

class SavedJobController extends Notifier<SavedJobState> {
  GetSavedJobsUseCase get _getSavedJobsUseCase =>
      ref.read(getSavedJobsUseCaseProvider);
  SaveJobUseCase get _saveJobUseCase => ref.read(saveJobUseCaseProvider);

  @override
  SavedJobState build() {
    Future.microtask(() => fetchSavedJobs());
    return SavedJobState();
  }

  // Fetch all saved jobs from API
  Future<void> fetchSavedJobs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final jobs = await _getSavedJobsUseCase();
      state = state.copyWith(isLoading: false, savedJobs: jobs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Toggle save/unsave a job (Optimistic Update)
  Future<void> toggleSaveJob(String jobId) async {
    // Prevent double-tap while already toggling
    if (state.togglingJobIds.contains(jobId)) return;

    //  Mark this job as "toggling"
    state = state.copyWith(togglingJobIds: {...state.togglingJobIds, jobId});

    //  Remember old state for rollback
    final wasSaved = state.isJobSaved(jobId);

    //  Instantly update the UI
    if (wasSaved) {
      // Remove from saved list
      state = state.copyWith(
        savedJobs: state.savedJobs.where((job) => job.id != jobId).toList(),
      );
    }
    try {
      final isNowSaved = await _saveJobUseCase(jobId);

      // If the API says it's saved and it wasn't in our list, re-fetch
      if (isNowSaved && !wasSaved) {
        await fetchSavedJobs();
      }

      // Remove from toggling set
      final newTogglingIds = {...state.togglingJobIds}..remove(jobId);
      state = state.copyWith(togglingJobIds: newTogglingIds);
    } catch (e) {
      // Rollback on error: re-fetch to get the correct state
      await fetchSavedJobs();

      final newTogglingIds = {...state.togglingJobIds}..remove(jobId);
      state = state.copyWith(
        togglingJobIds: newTogglingIds,
        errorMessage: e.toString(),
      );
    }
  }
}
