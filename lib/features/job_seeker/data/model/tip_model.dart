import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/job_seeker/domain/entities/tip_entity.dart';

class TipModel extends TipEntity {
  TipModel({
    super.id,
    super.title,
    super.content,
    super.imageUrl,
    super.category,
    super.createdAt,
    super.authorName,
    super.authorAvatarUrl,
  });

  factory TipModel.fromJson(DataMap json) {
    return TipModel(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      createdAt: json['createdAt'],
      authorName: json['author'] != null ? json['author']['name'] : null,
      authorAvatarUrl: json['author'] != null
          ? json['author']['avatarUrl']
          : null,
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
      'author': {
        if (authorName != null) 'name': authorName,
        if (authorAvatarUrl != null) 'avatarUrl': authorAvatarUrl,
      },
    };
  }
}
