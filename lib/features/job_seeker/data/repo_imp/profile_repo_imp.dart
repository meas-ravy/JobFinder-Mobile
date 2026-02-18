import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/job_seeker/data/server/profile_server.dart';
import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileServer _profileServer;

  ProfileRepositoryImpl(this._profileServer);

  @override
  Future<ProfileEntity> getProfile() {
    return _profileServer.getProfile();
  }

  @override
  Future<ProfileEntity> createProfile(DataMap body) {
    return _profileServer.createProfile(body);
  }

  @override
  Future<ProfileEntity> updateProfile(DataMap body) {
    return _profileServer.updateProfile(body);
  }
}
