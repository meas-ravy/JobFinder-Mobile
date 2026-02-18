import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> createProfile(Map<String, dynamic> body);
  Future<ProfileEntity> updateProfile(Map<String, dynamic> body);
}
