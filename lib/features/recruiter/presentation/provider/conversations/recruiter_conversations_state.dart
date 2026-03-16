

class RecruiterConversationsState {
  const RecruiterConversationsState({
    this.isLoading = false,
    this.isInitial = true,
    this.errorMessage,
    this.conversations = const [],
  });

  final bool isLoading;
  final bool isInitial;
  final String? errorMessage;
  final List<dynamic> conversations;

  RecruiterConversationsState copyWith({
    bool? isLoading,
    bool? isInitial,
    String? errorMessage,
    List<dynamic>? conversations,
  }) {
    return RecruiterConversationsState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      errorMessage: errorMessage,
      conversations: conversations ?? this.conversations,
    );
  }
}
