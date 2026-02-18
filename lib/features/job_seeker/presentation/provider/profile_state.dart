import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final ProfileEntity? profile;
  final bool isSetupShown;

  ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
    this.isSetupShown = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    ProfileEntity? profile,
    bool? isSetupShown,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
      isSetupShown: isSetupShown ?? this.isSetupShown,
    );
  }
}
