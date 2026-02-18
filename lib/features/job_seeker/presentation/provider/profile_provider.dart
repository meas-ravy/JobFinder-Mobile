import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/data/repo_imp/profile_repo_imp.dart';
import 'package:job_finder/features/job_seeker/data/server/profile_server.dart';
import 'package:job_finder/features/job_seeker/domain/repos/profile_repository.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/profile_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_controller.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_state.dart';

final profileServerProvider = Provider<ProfileServer>((ref) {
  return ProfileServerImpl();
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.watch(profileServerProvider));
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final createProfileUseCaseProvider = Provider<CreateProfileUseCase>((ref) {
  return CreateProfileUseCase(ref.watch(profileRepositoryProvider));
});

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      final controller = ProfileController(
        getProfileUseCase: ref.watch(getProfileUseCaseProvider),
        updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
        createProfileUseCase: ref.watch(createProfileUseCaseProvider),
      );

      // Auto fetch profile when provider is initialized
      controller.fetchProfile();

      return controller;
    });
