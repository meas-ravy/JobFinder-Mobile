import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/application_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/application_entity.dart';

abstract class ApplicationServer {
  Future<List<ApplicationEntity>> getMyApplications();
  Future<ApplicationEntity> getApplicationDetails(String id);
}

class ApplicationServerImpl implements ApplicationServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    try {
      final response = await dio.get(ApiEnpoint.myApplications);
      final List<dynamic> applicationsJson =
          response.data['applications'] ?? [];
      return applicationsJson
          .map((json) => ApplicationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApplicationEntity> getApplicationDetails(String id) async {
    try {
      final response = await dio.get(ApiEnpoint.applicationDetails(id));
      final applicationJson = response.data['application'] ?? response.data;
      return ApplicationModel.fromJson(applicationJson);
    } catch (e) {
      rethrow;
    }
  }
}
