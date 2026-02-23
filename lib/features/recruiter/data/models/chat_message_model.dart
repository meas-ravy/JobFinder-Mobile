import 'package:firebase_database/firebase_database.dart';

class ChatMessageModel {
  final String? id;
  final String content;
  final String senderId;
  final String senderType;
  final dynamic timestamp;
  final String status;
  final String? type; // 'text' or 'job_card'
  final String? jobId;
  final Map<String, dynamic>? jobData;

  ChatMessageModel({
    this.id,
    required this.content,
    required this.senderId,
    required this.senderType,
    this.timestamp,
    this.status = 'sent',
    this.type = 'text',
    this.jobId,
    this.jobData,
  });

  factory ChatMessageModel.fromMap(String id, Map<dynamic, dynamic> map) {
    final timestamp = map['timestamp'];

    // Convert jobData if it exists
    Map<String, dynamic>? parsedJobData;
    if (map['jobData'] != null && map['jobData'] is Map) {
      parsedJobData = Map<String, dynamic>.from(map['jobData']);
    }

    return ChatMessageModel(
      id: id,
      content: (map['content'] ?? '').toString(),
      senderId: (map['senderId'] ?? '').toString(),
      senderType: (map['senderType'] ?? '').toString(),
      timestamp: timestamp,
      status: (map['status'] ?? 'sent').toString(),
      type: (map['type'] ?? 'text').toString(),
      jobId: map['jobId']?.toString(),
      jobData: parsedJobData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'senderId': senderId,
      'senderType': senderType,
      'timestamp': timestamp ?? ServerValue.timestamp,
      'status': status,
      'type': type,
      if (jobId != null) 'jobId': jobId,
      if (jobData != null) 'jobData': jobData,
    };
  }
}
