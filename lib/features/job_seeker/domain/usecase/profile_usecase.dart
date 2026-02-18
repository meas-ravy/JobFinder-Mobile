import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';
import 'package:job_finder/features/job_seeker/domain/repos/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _profileRepository;

  GetProfileUseCase(this._profileRepository);

  Future<ProfileEntity> call() {
    return _profileRepository.getProfile();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  Future<ProfileEntity> call(Map<String, dynamic> body) {
    return _profileRepository.updateProfile(body);
  }
}

class CreateProfileUseCase {
  final ProfileRepository _profileRepository;

  CreateProfileUseCase(this._profileRepository);

  Future<ProfileEntity> call(Map<String, dynamic> body) {
    return _profileRepository.createProfile(body);
  }
}
