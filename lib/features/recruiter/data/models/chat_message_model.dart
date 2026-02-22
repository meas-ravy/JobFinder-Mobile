import 'package:firebase_database/firebase_database.dart';

class ChatMessageModel {
  final String? id;
  final String content;
  final String senderId;
  final String senderType;
  final dynamic timestamp;
  final String status;
  final String? jobId;

  ChatMessageModel({
    this.id,
    required this.content,
    required this.senderId,
    required this.senderType,
    this.timestamp,
    this.status = 'sent',
    this.jobId,
  });

  factory ChatMessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final timestamp = map['timestamp'];
    return ChatMessageModel(
      id: id,
      content: (map['content'] ?? '').toString(),
      senderId: (map['senderId'] ?? '').toString(),
      senderType: (map['senderType'] ?? '').toString(),
      timestamp: timestamp,
      status: (map['status'] ?? 'sent').toString(),
      jobId: map['jobId']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'senderId': senderId,
      'senderType': senderType,
      'timestamp': timestamp ?? ServerValue.timestamp,
      'status': status,
      if (jobId != null) 'jobId': jobId,
    };
  }
}
