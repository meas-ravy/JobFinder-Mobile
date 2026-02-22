import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class ApplicationEntity {
  final String id;
  final String jobId;
  final String status;
  final DateTime createdAt;
  final JobEntity? job;

  ApplicationEntity({
    required this.id,
    required this.jobId,
    required this.status,
    required this.createdAt,
    this.job,
  });
}
