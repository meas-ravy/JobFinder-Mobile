enum ChatAction {
  getConversations,
  updateConversation,
  getAgoraToken,
  signalCall,
}

class ChatState {
  const ChatState({
    this.isLoading = false,
    this.errorMessage,
    this.conversations = const [],
    this.lastAction,
    this.agoraToken,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> conversations;
  final ChatAction? lastAction;
  final String? agoraToken;

  ChatState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? conversations,
    ChatAction? lastAction,
    String? agoraToken,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      conversations: conversations ?? this.conversations,
      lastAction: lastAction ?? this.lastAction,
      agoraToken: agoraToken ?? this.agoraToken,
    );
  }
}
