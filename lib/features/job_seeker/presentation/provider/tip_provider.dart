import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/tip_repository_impl.dart';
import 'package:job_finder/features/job_seeker/data/server/tip_server.dart';
import 'package:job_finder/features/job_seeker/domain/repos/tip_repository.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/tip_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/tip_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/tip_state.dart';

final tipServerProvider = Provider<TipServer>((ref) {
  return TipServerImpl();
});

final tipRepositoryProvider = Provider<TipRepository>((ref) {
  return TipRepositoryImpl(ref.watch(tipServerProvider));
});

final getTipsUseCaseProvider = Provider<GetTipsUseCase>((ref) {
  return GetTipsUseCase(ref.watch(tipRepositoryProvider));
});

final getTipDetailUseCaseProvider = Provider<GetTipDetailUseCase>((ref) {
  return GetTipDetailUseCase(ref.watch(tipRepositoryProvider));
});

final tipControllerProvider = StateNotifierProvider<TipController, TipState>((
  ref,
) {
  final controller = TipController(
    getTipsUseCase: ref.watch(getTipsUseCaseProvider),
    getTipDetailUseCase: ref.watch(getTipDetailUseCaseProvider),
  );

  // Fetch tips on initialization
  controller.fetchTips();

  return controller;
});
