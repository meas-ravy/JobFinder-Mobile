enum ChatAction {
  getConversations,
  updateConversation,
  getAgoraToken,
  signalCall,
}

class ChatState {
  const ChatState({
    this.isLoading = false,
    this.isInitial = true,
    this.errorMessage,
    this.conversations = const [],
    this.lastAction,
    this.agoraToken,
    this.agoraAppId,
    this.agoraUid,
  });

  final bool isLoading;
  final bool isInitial;
  final String? errorMessage;
  final List<dynamic> conversations;
  final ChatAction? lastAction;
  final String? agoraToken;
  final String? agoraAppId;
  final String? agoraUid;

  ChatState copyWith({
    bool? isLoading,
    bool? isInitial,
    String? errorMessage,
    List<dynamic>? conversations,
    ChatAction? lastAction,
    String? agoraToken,
    String? agoraAppId,
    String? agoraUid,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      errorMessage: errorMessage ?? this.errorMessage,
      conversations: conversations ?? this.conversations,
      lastAction: lastAction ?? this.lastAction,
      agoraToken: agoraToken ?? this.agoraToken,
      agoraAppId: agoraAppId ?? this.agoraAppId,
      agoraUid: agoraUid ?? this.agoraUid,
    );
  }
}
