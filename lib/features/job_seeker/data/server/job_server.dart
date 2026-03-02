import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/job_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';
import 'package:job_finder/features/job_seeker/domain/entities/paginated_jobs.dart';
import 'package:job_finder/core/helper/pagination.dart';

abstract class JobServer {
  Future<List<JobEntity>> getRecommendedJobs();
  Future<PaginatedJobs> getRecentJobs({
    String? category,
    int page = 1,
    int limit = 20,
  });
  Future<JobEntity> getJobById(String id);
  Future<bool> saveJob(String id);
  Future<List<JobEntity>> getSavedJobs();
  Future<void> applyJob({
    required String jobId,
    required String fullName,
    required String email,
    required String resumeUrl,
    String? coverLetter,
  });
}

class JobServerImpl implements JobServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  Future<List<JobEntity>> getRecommendedJobs() async {
    try {
      final response = await dio.get(
        ApiEnpoint.jobs,
        queryParameters: {'section': 'recommended'},
      );

      final List<dynamic> jobsJson = response.data['jobs'] ?? [];
      return jobsJson.map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PaginatedJobs> getRecentJobs({
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final DataMap queryParams = {
        'section': 'recent',
        'page': page,
        'limit': limit,
      };
      
      if (category != null) {
        queryParams['category'] = category == 'All' ? 'all' : category;
      }

      final response = await dio.get(
        ApiEnpoint.jobs,
        queryParameters: queryParams,
      );

      final List<dynamic> jobsJson = response.data['jobs'] ?? [];
      final jobs = jobsJson.map((json) => JobModel.fromJson(json)).toList();

      final paginationJson = response.data['pagination'];
      final pagination = paginationJson != null
          ? PaginationInfo.fromJson(paginationJson)
          : PaginationInfo(
              page: page,
              limit: limit,
              totalCount: 0,
              totalPages: 1,
            );

      return PaginatedJobs(jobs: jobs, pagination: pagination);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<JobEntity> getJobById(String id) async {
    try {
      final response = await dio.get('${ApiEnpoint.jobs}/$id');
      return JobModel.fromJson(response.data['job']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> saveJob(String id) async {
    try {
      final response = await dio.post('${ApiEnpoint.jobs}/$id/save');
      // Backend returns { isSaved: true/false } or { is_saved: true/false }
      final data = response.data;
      if (data != null && data['success'] == true) {
        return data['isSaved'] ?? data['is_saved'] ?? false;
      }
      return data['isSaved'] ?? data['is_saved'] ?? false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<JobEntity>> getSavedJobs() async {
    try {
      final response = await dio.get('${ApiEnpoint.jobs}/saved');
      final List<dynamic> jobsJson = response.data['jobs'] ?? [];
      return jobsJson.map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> applyJob({
    required String jobId,
    required String fullName,
    required String email,
    required String resumeUrl,
    String? coverLetter,
  }) async {
    try {
      await dio.post(
        ApiEnpoint.applyJob(jobId),
        data: {
          'fullName': fullName,
          'email': email,
          'resumeUrl': resumeUrl,
          'coverLetter': coverLetter,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
