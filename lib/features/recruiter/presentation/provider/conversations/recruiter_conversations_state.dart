

class RecruiterConversationsState {
  const RecruiterConversationsState({
    this.isLoading = false,
    this.errorMessage,
    this.conversations = const [],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> conversations;

  RecruiterConversationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<dynamic>? conversations,
  }) {
    return RecruiterConversationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      conversations: conversations ?? this.conversations,
    );
  }
}
