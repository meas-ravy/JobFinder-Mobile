import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/job_seeker/domain/usecase/profile_usecase.dart';
import 'package:job_finder/features/job_seeker/presentation/provider/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final CreateProfileUseCase _createProfileUseCase;

  ProfileController({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required CreateProfileUseCase createProfileUseCase,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _createProfileUseCase = createProfileUseCase,
       super(ProfileState());

  Future<void> fetchProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _getProfileUseCase();
      state = state.copyWith(isLoading: false, profile: profile);
    } catch (e) {
      // If it's a 404 or profile not found error, we don't treat it as an error
      // because it just means the user needs to set up their profile.
      if (e.toString().contains('404')) {
        state = state.copyWith(
          isLoading: false,
          profile: null,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<bool> createProfile(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _createProfileUseCase(body);
      state = state.copyWith(isLoading: false, profile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _updateProfileUseCase(body);
      state = state.copyWith(isLoading: false, profile: profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  void markSetupShown() {
    state = state.copyWith(isSetupShown: true);
  }
}
