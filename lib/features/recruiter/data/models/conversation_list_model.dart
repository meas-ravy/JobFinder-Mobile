class ConversationListModel {
  final String id;
  final String? lastMessageContent;
  final String? lastMessageTimestamp;
  final OtherParticipant otherParticipant;
  final int unreadCount;

  ConversationListModel({
    required this.id,
    this.lastMessageContent,
    this.lastMessageTimestamp,
    required this.otherParticipant,
    this.unreadCount = 0,
  });

  factory ConversationListModel.fromJson(Map<String, dynamic> json) {
    return ConversationListModel(
      id: json['id'] ?? '',
      lastMessageContent: json['lastMessageContent'],
      lastMessageTimestamp: json['lastMessageTimestamp'],
      otherParticipant: OtherParticipant.fromJson(
        json['otherParticipant'] ?? {},
      ),
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class OtherParticipant {
  final String id;
  final String name;
  final String? avatar;

  OtherParticipant({required this.id, required this.name, this.avatar});

  factory OtherParticipant.fromJson(Map<String, dynamic> json) {
    return OtherParticipant(
      id: json['id'] ?? '',
      name: json['name'] ?? json['fullName'] ?? 'Unknown',
      avatar: json['avatar'] ?? json['image'],
    );
  }
}
