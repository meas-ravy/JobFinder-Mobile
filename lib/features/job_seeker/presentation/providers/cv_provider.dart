import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/domain/entities/cv_entity.dart';

import 'package:job_finder/features/job_seeker/data/repo_imp/cv_repository_impl.dart';
import 'package:job_finder/features/job_seeker/domain/repos/cv_repository.dart';
import 'package:job_finder/main.dart';

final cvRepositoryProvider = Provider<CvRepository>((ref) {
  final objectBox = ref.watch(objectBoxProvider);
  return CvRepositoryImpl(objectBox);
});

final cvListProvider =
    AsyncNotifierProvider.autoDispose<CvListNotifier, List<CvEntity>>(
      CvListNotifier.new,
    );

class CvListNotifier extends AutoDisposeAsyncNotifier<List<CvEntity>> {
  @override
  Future<List<CvEntity>> build() async {
    final repository = ref.watch(cvRepositoryProvider);
    return repository.getAllCvs();
  }

  Future<void> deleteCv(int id) async {
    final repository = ref.read(cvRepositoryProvider);

    if (state.hasValue) {
      final previousState = state.value!;
      // 1. Optimistic Update: Remove from UI immediately
      state = AsyncData(previousState.where((cv) => cv.id != id).toList());

      try {
        await repository.deleteCv(id);
      } catch (e) {
        // 2. Fallback: Restore state if delete fails
        state = AsyncData(previousState);
        rethrow;
      }
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}
