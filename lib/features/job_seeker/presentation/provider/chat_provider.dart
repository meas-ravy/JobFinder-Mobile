import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/chat/data/server/chat_server.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/chat_state.dart';

final chatServerProvider = Provider<ChatServer>((ref) {
  return ChatServerImpl();
});

final jobSeekerChatControllerProvider =
    StateNotifierProvider<JobSeekerChatController, ChatState>((ref) {
      return JobSeekerChatController(chatServer: ref.watch(chatServerProvider));
    });
