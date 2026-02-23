import 'package:job_finder/features/job_seeker/domain/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final bool isFetched;
  final String? errorMessage;
  final ProfileEntity? profile;
  final bool isSetupShown;

  ProfileState({
    this.isLoading = false,
    this.isFetched = false,
    this.errorMessage,
    this.profile,
    this.isSetupShown = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isFetched,
    String? errorMessage,
    ProfileEntity? profile,
    bool? isSetupShown,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isFetched: isFetched ?? this.isFetched,
      errorMessage: errorMessage ?? this.errorMessage,
      profile: profile ?? this.profile,
      isSetupShown: isSetupShown ?? this.isSetupShown,
    );
  }
}
