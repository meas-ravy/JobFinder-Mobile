import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/job_seeker/data/model/profile_model.dart';
import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';

abstract class ProfileServer {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> createProfile(DataMap body);
  Future<ProfileEntity> updateProfile(DataMap body);
}

class ProfileServerImpl implements ProfileServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  Future<ProfileEntity> getProfile() async {
    try {
      final response = await dio.get(ApiEnpoint.profile);
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileEntity> createProfile(DataMap body) async {
    try {
      final response = await dio.post(ApiEnpoint.profile, data: body);
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileEntity> updateProfile(DataMap body) async {
    try {
      final response = await dio.put(ApiEnpoint.profile, data: body);
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
