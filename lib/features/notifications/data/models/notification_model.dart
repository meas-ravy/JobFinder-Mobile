import 'package:job_finder/core/helper/typedef.dart';

class NotificationModel {
  final String id;
  final String title;
  final String content;
  final bool isRead;
  final String? link;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    this.link,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(DataMap json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      isRead: json['isRead'] ?? false,
      link: json['link'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? content,
    bool? isRead,
    String? link,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      link: link ?? this.link,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
