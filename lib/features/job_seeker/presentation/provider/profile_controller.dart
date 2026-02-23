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
      state = state.copyWith(
        isLoading: false,
        isFetched: true,
        profile: profile,
      );
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains("type 'Null' is not a subtype of type") ||
          e.toString().contains("type 'Null' is not a subtype")) {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
          profile: null,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
          errorMessage: e.toString(),
        );
      }
    }
  }

  Future<bool> createProfile(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _createProfileUseCase(body);
      state = state.copyWith(
        isLoading: false,
        isFetched: true,
        profile: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetched: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> body) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _updateProfileUseCase(body);
      state = state.copyWith(
        isLoading: false,
        isFetched: true,
        profile: profile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetched: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void markSetupShown() {
    state = state.copyWith(isSetupShown: true);
  }
}
