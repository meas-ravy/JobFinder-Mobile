import 'package:job_finder/features/job_seeker/data/model/job_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';

class ApplicationModel extends ApplicationEntity {
  ApplicationModel({
    required super.id,
    required super.jobId,
    required super.status,
    required super.createdAt,
    super.job,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] ?? json['_id'] ?? '',
      jobId: json['jobId'] ?? '',
      status:
          (json['status'] ?? json['applicationStatus'])?.toString().trim() ??
          'Submitted',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      job: json['job'] != null ? JobModel.fromJson(json['job']) : null,
    );
  }
}
