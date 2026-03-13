import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/company/company_profile_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_provider.dart';

class CompanyProfileController extends StateNotifier<CompanyProfileState> {
  CompanyProfileController({
    required CreateCompanyUseCase createCompanyUseCase,
    required GetCompanyProfileUseCase getCompanyProfileUseCase,
    required UpdateCompanyUseCase updateCompanyUseCase,
  }) : _createCompanyUseCase = createCompanyUseCase,
       _getCompanyProfileUseCase = getCompanyProfileUseCase,
       _updateCompanyUseCase = updateCompanyUseCase,
       super(const CompanyProfileState()) {
    getCompanyProfile();
  }

  final CreateCompanyUseCase _createCompanyUseCase;
  final GetCompanyProfileUseCase _getCompanyProfileUseCase;
  final UpdateCompanyUseCase _updateCompanyUseCase;

  CompanyModel? _parseCompany(DataMap data) {
    if (data.containsKey('name') && data.containsKey('contactEmail')) {
      return CompanyModel.fromJson(data);
    }
    if (data['company'] is Map<String, dynamic>) {
      return CompanyModel.fromJson(data['company'] as Map<String, dynamic>);
    }
    if (data['data'] is Map<String, dynamic>) {
      final innerData = data['data'] as Map<String, dynamic>;
      if (innerData['company'] is Map<String, dynamic>) {
        return CompanyModel.fromJson(
          innerData['company'] as Map<String, dynamic>,
        );
      }
      if (innerData.containsKey('name')) {
        return CompanyModel.fromJson(innerData);
      }
    }
    return null;
  }

  Future<void> getCompanyProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _getCompanyProfileUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, company: parsed);
      },
    );
  }

  Future<void> createCompany(DataMap company) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _createCompanyUseCase(
      CreateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, company: parsed);
      },
    );
  }

  Future<void> updateCompany(DataMap company) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _updateCompanyUseCase(
      UpdateCompanyParams(company: company),
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (data) {
        final parsed = _parseCompany(data);
        state = state.copyWith(isLoading: false, company: parsed);
      },
    );
  }
}

final companyProfileProvider =
    StateNotifierProvider<CompanyProfileController, CompanyProfileState>((ref) {
      return CompanyProfileController(
        createCompanyUseCase: ref.watch(createCompanyUseCaseProvider),
        getCompanyProfileUseCase: ref.watch(getCompanyProfileUseCaseProvider),
        updateCompanyUseCase: ref.watch(updateCompanyUseCaseProvider),
      );
    });
