import 'package:job_finder/features/recruiter/data/models/company_model.dart';

class CompanyProfileState {
  const CompanyProfileState({
    this.isLoading = false,
    this.isInitial = true,
    this.errorMessage,
    this.company,
  });

  final bool isLoading;
  final bool isInitial;
  final String? errorMessage;
  final CompanyModel? company;

  CompanyProfileState copyWith({
    bool? isLoading,
    bool? isInitial,
    String? errorMessage,
    CompanyModel? company,
  }) {
    return CompanyProfileState(
      isLoading: isLoading ?? this.isLoading,
      isInitial: isInitial ?? this.isInitial,
      errorMessage: errorMessage,
      company: company ?? this.company,
    );
  }
}
