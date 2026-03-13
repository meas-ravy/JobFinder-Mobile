import 'package:equatable/equatable.dart';

class ApplicationEntity extends Equatable {
  final String id;
  final String status;
  final String resumeUrl;
  final DateTime submittedAt;
  final ApplicationJobEntity job;
  final ApplicationJobSeekerEntity jobSeeker;

  const ApplicationEntity({
    required this.id,
    required this.status,
    required this.resumeUrl,
    required this.submittedAt,
    required this.job,
    required this.jobSeeker,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    resumeUrl,
    submittedAt,
    job,
    jobSeeker,
  ];
}

class ApplicationJobEntity extends Equatable {
  final String id;
  final String title;
  final String location;

  const ApplicationJobEntity({
    required this.id,
    required this.title,
    required this.location,
  });

  @override
  List<Object?> get props => [id, title, location];
}

class ApplicationJobSeekerEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const ApplicationJobSeekerEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, email, phone, avatarUrl];
}
