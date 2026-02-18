import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/tip_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/tip_state.dart';

class TipController extends StateNotifier<TipState> {
  final GetTipsUseCase _getTipsUseCase;
  final GetTipDetailUseCase _getTipDetailUseCase;

  TipController({
    required GetTipsUseCase getTipsUseCase,
    required GetTipDetailUseCase getTipDetailUseCase,
  }) : _getTipsUseCase = getTipsUseCase,
       _getTipDetailUseCase = getTipDetailUseCase,
       super(TipState());

  Future<void> fetchTips() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tips = await _getTipsUseCase();
      state = state.copyWith(isLoading: false, tips: tips);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchTipDetail(String id) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentTip: null,
    );
    try {
      final tip = await _getTipDetailUseCase(id);
      state = state.copyWith(isLoading: false, currentTip: tip);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
