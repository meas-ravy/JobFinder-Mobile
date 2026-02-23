import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/chat/data/server/chat_server.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_state.dart';

class JobSeekerChatController extends StateNotifier<ChatState> {
  final ChatServer _chatServer;

  JobSeekerChatController({required ChatServer chatServer})
    : _chatServer = chatServer,
      super(const ChatState());

  Future<void> getConversations() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _chatServer.getConversations();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final List<dynamic> conversations =
            data['conversations'] ?? data['data'] ?? [];
        state = state.copyWith(
          isLoading: false,
          conversations: conversations,
          lastAction: ChatAction.getConversations,
        );
      },
    );
  }

  Future<void> updateConversation(String id, DataMap body) async {
    state = state.copyWith(lastAction: ChatAction.updateConversation);
    final result = await _chatServer.updateConversation(id, body);
    result.fold(
      (failure) {
        // Silent failure
      },
      (data) {
        // Updated
      },
    );
  }

  Future<void> getAgoraToken(String channelName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _chatServer.getAgoraToken(channelName);
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final token = data['token'] ?? data['data']?['token'];
        final appId = data['appId'] ?? data['data']?['appId'];
        state = state.copyWith(
          isLoading: false,
          agoraToken: token,
          agoraAppId: appId,
          lastAction: ChatAction.getAgoraToken,
        );
      },
    );
  }

  Future<void> signalCall(DataMap body) async {
    state = state.copyWith(lastAction: ChatAction.signalCall);
    final result = await _chatServer.signalCall(body);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (data) {
        // Call signaled
      },
    );
  }
}
