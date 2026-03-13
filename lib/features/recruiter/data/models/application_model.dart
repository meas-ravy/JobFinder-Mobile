import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_entity.dart';

class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.status,
    required super.resumeUrl,
    required super.submittedAt,
    required super.job,
    required super.jobSeeker,
  });

  factory ApplicationModel.fromJson(DataMap json) {
    return ApplicationModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'].toString())
          : DateTime.now(),
      job: ApplicationJobModel.fromJson(
        Map<String, dynamic>.from(json['job'] ?? {}),
      ),
      jobSeeker: ApplicationJobSeekerModel.fromJson(
        Map<String, dynamic>.from(json['jobSeeker'] ?? json['user'] ?? {}),
      ),
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'status': status,
      'resumeUrl': resumeUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'job': (job as ApplicationJobModel).toJson(),
      'jobSeeker': (jobSeeker as ApplicationJobSeekerModel).toJson(),
    };
  }
}

class ApplicationJobModel extends ApplicationJobEntity {
  const ApplicationJobModel({
    required super.id,
    required super.title,
    required super.location,
  });

  factory ApplicationJobModel.fromJson(Map<String, dynamic> json) {
    return ApplicationJobModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
    };
  }
}

class ApplicationJobSeekerModel extends ApplicationJobSeekerEntity {
  const ApplicationJobSeekerModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    super.avatarUrl,
  });

  factory ApplicationJobSeekerModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map ? json['profile'] as Map : {};
    return ApplicationJobSeekerModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      fullName: (json['fullName'] ?? profile['fullName'])?.toString() ?? '',
      email: (json['email'] ?? profile['email'])?.toString() ?? '',
      phone: (json['phone'] ?? profile['phone'])?.toString(),
      avatarUrl: (json['avatarUrl'] ?? profile['avatarUrl'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }
}
