import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/conversations/recruiter_conversations_state.dart';

class RecruiterConversationsController
    extends StateNotifier<RecruiterConversationsState> {
  RecruiterConversationsController({
    required GetConversationsUseCase getConversationsUseCase,
    required UpdateConversationUseCase updateConversationUseCase,
  }) : _getConversationsUseCase = getConversationsUseCase,
       _updateConversationUseCase = updateConversationUseCase,
       super(const RecruiterConversationsState());

  final GetConversationsUseCase _getConversationsUseCase;
  final UpdateConversationUseCase _updateConversationUseCase;

  Future<void> getConversations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getConversationsUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isInitial: false,
          errorMessage: failure.message,
        );
      },
      (data) {
        final List<dynamic> conversations =
            data['conversations'] ?? data['data'] ?? [];
        state = state.copyWith(
          isLoading: false,
          isInitial: false,
          conversations: conversations,
        );
      },
    );
  }

  Future<void> updateConversation(String id, DataMap body) async {
    final result = await _updateConversationUseCase(
      UpdateConversationParams(id: id, body: body),
    );
    result.fold(
      (failure) {
        // Silent failure to avoid disrupting UI
      },
      (data) {
        getConversations(); // Trigger refetch of conversations
      },
    );
  }
}
