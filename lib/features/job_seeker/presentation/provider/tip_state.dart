import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';

class TipState {
  final bool isLoading;
  final List<TipEntity> tips;
  final TipEntity? currentTip;
  final String? errorMessage;

  TipState({
    this.isLoading = false,
    this.tips = const [],
    this.currentTip,
    this.errorMessage,
  });

  TipState copyWith({
    bool? isLoading,
    List<TipEntity>? tips,
    TipEntity? currentTip,
    String? errorMessage,
  }) {
    return TipState(
      isLoading: isLoading ?? this.isLoading,
      tips: tips ?? this.tips,
      currentTip: currentTip ?? this.currentTip,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
