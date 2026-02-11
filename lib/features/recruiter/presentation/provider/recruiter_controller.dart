import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';

class RecruiterController extends StateNotifier<RecruiterState> {
  RecruiterController({
    required CreateCompanyUseCase createCompanyUseCase,
    required GetCompanyProfileUseCase getCompanyProfileUseCase,
    required UpdateCompanyUseCase updateCompanyUseCase,
  }) : _createCompanyUseCase = createCompanyUseCase,
       _getCompanyProfileUseCase = getCompanyProfileUseCase,
       _updateCompanyUseCase = updateCompanyUseCase,
       super(const RecruiterState()) {
    getCompanyProfile();
  }

  final CreateCompanyUseCase _createCompanyUseCase;
  final GetCompanyProfileUseCase _getCompanyProfileUseCase;
  final UpdateCompanyUseCase _updateCompanyUseCase;

  Future<void> updateCompany(DataMap company) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.updateCompany,
    );
    final result = await _updateCompanyUseCase(
      UpdateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  Future<void> createCompany(DataMap company) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.createCompany,
    );
    final result = await _createCompanyUseCase(
      CreateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }

  Future<void> getCompanyProfile() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      lastAction: RecruiterAction.getCompanyProfile,
    );
    final result = await _getCompanyProfileUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        state = state.copyWith(isLoading: false, data: data);
      },
    );
  }
}
