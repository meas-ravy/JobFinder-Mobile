import 'package:job_finder/core/helper/pagination.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

class PaginatedJobs {
  final List<JobEntity> jobs;
  final PaginationInfo pagination;

  PaginatedJobs({required this.jobs, required this.pagination});
}
