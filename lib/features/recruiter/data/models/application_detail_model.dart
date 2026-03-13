import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_detail_entity.dart';

class ApplicationDetailModel extends ApplicationDetailEntity {
  const ApplicationDetailModel({
    required super.id,
    super.jobId,
    required super.status,
    required super.resumeUrl,
    super.coverLetter,
    super.recruiterNotes,
    required super.submittedAt,
    super.reviewedAt,
    super.updatedAt,
    required super.job,
    required super.jobSeeker,
  });

  factory ApplicationDetailModel.fromJson(DataMap json) {
    return ApplicationDetailModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      jobId: json['jobId']?.toString(),
      status: json['status']?.toString() ?? '',
      resumeUrl: json['resumeUrl']?.toString() ?? '',
      coverLetter: json['coverLetter']?.toString(),
      recruiterNotes: json['recruiterNotes']?.toString(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'].toString())
          : DateTime.now(),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : null,
      job: ApplicationDetailJobModel.fromJson(
        Map<String, dynamic>.from(json['job'] ?? {}),
      ),
      jobSeeker: ApplicationDetailJobSeekerModel.fromJson(
        Map<String, dynamic>.from(json['jobSeeker'] ?? json['user'] ?? {}),
      ),
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'status': status,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'recruiterNotes': recruiterNotes,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'job': (job as ApplicationDetailJobModel).toJson(),
      'jobSeeker': (jobSeeker as ApplicationDetailJobSeekerModel).toJson(),
    };
  }
}

class ApplicationDetailJobModel extends ApplicationDetailJobEntity {
  const ApplicationDetailJobModel({
    required super.id,
    required super.title,
    super.category,
    super.employmentType,
    required super.location,
  });

  factory ApplicationDetailJobModel.fromJson(Map<String, dynamic> json) {
    return ApplicationDetailJobModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString(),
      employmentType: json['employmentType']?.toString(),
      location: json['location']?.toString() ?? '',
    );
  }

  DataMap toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'employmentType': employmentType,
      'location': location,
    };
  }
}

class ApplicationDetailJobSeekerModel extends ApplicationDetailJobSeekerEntity {
  const ApplicationDetailJobSeekerModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phone,
    super.avatarUrl,
    super.dateOfBirth,
    super.gender,
  });

  factory ApplicationDetailJobSeekerModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map ? json['profile'] as Map : {};
    return ApplicationDetailJobSeekerModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      fullName: (json['fullName'] ?? profile['fullName'])?.toString() ?? '',
      email: (json['email'] ?? profile['email'])?.toString() ?? '',
      phone: (json['phone'] ?? profile['phone'])?.toString(),
      avatarUrl: (json['avatarUrl'] ?? profile['avatarUrl'])?.toString(),
      dateOfBirth: (json['dateOfBirth'] ?? profile['dateOfBirth']) != null
          ? DateTime.parse((json['dateOfBirth'] ?? profile['dateOfBirth']).toString())
          : null,
      gender: (json['gender'] ?? profile['gender'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
    };
  }
}
