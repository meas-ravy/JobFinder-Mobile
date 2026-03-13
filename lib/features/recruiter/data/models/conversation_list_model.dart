import 'package:job_finder/core/helper/typedef.dart';

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

  factory ConversationListModel.fromJson(DataMap json) {
    return ConversationListModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      lastMessageContent: json['lastMessageContent']?.toString(),
      lastMessageTimestamp:
          json['lastMessageTimestamp']?.toString() ??
          json['lastMessageAt']?.toString() ??
          json['updatedAt']?.toString(),
      otherParticipant: OtherParticipant.fromJson(
        (json['otherParticipant'] is Map)
            ? Map<String, dynamic>.from(json['otherParticipant'])
            : <String, dynamic>{},
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

  factory OtherParticipant.fromJson(DataMap json) {
    return OtherParticipant(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? 'User',
      avatar:
          json['avatar']?.toString() ??
          json['image']?.toString() ??
          json['avatarUrl']?.toString(),
    );
  }
}
