import 'package:equatable/equatable.dart';

class ApplicationDetailEntity extends Equatable {
  final String id;
  final String? jobId;
  final String status;
  final String resumeUrl;
  final String? coverLetter;
  final String? recruiterNotes;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final DateTime? updatedAt;
  final ApplicationDetailJobEntity job;
  final ApplicationDetailJobSeekerEntity jobSeeker;

  const ApplicationDetailEntity({
    required this.id,
    this.jobId,
    required this.status,
    required this.resumeUrl,
    this.coverLetter,
    this.recruiterNotes,
    required this.submittedAt,
    this.reviewedAt,
    this.updatedAt,
    required this.job,
    required this.jobSeeker,
  });

  @override
  List<Object?> get props => [
        id,
        jobId,
        status,
        resumeUrl,
        coverLetter,
        recruiterNotes,
        submittedAt,
        reviewedAt,
        updatedAt,
        job,
        jobSeeker,
      ];
}

class ApplicationDetailJobEntity extends Equatable {
  final String id;
  final String title;
  final String? category;
  final String? employmentType;
  final String location;

  const ApplicationDetailJobEntity({
    required this.id,
    required this.title,
    this.category,
    this.employmentType,
    required this.location,
  });

  @override
  List<Object?> get props => [id, title, category, employmentType, location];
}

class ApplicationDetailJobSeekerEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;

  const ApplicationDetailJobSeekerEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        avatarUrl,
        dateOfBirth,
        gender,
      ];
}
