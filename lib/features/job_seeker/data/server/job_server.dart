import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/job_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/job_entity.dart';

abstract class JobServer {
  Future<List<JobEntity>> getRecommendedJobs();
  Future<List<JobEntity>> getRecentJobs({String? category});
  Future<JobEntity> getJobById(String id);
  Future<bool> saveJob(String id);
  Future<List<JobEntity>> getSavedJobs();
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
  Future<List<JobEntity>> getRecentJobs({String? category}) async {
    try {
      final Map<String, dynamic> queryParams = {'section': 'recent'};
      if (category != null) {
        queryParams['category'] = category == 'All' ? 'all' : category;
      }

      final response = await dio.get(
        ApiEnpoint.jobs,
        queryParameters: queryParams,
      );

      final List<dynamic> jobsJson = response.data['jobs'] ?? [];
      return jobsJson.map((json) => JobModel.fromJson(json)).toList();
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
      // Backend returns { isSaved: true/false }
      return response.data['isSaved'] ?? false;
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
}
