import 'package:job_finder/features/recruiter/data/models/company_model.dart';

class CompanyProfileState {
  const CompanyProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.company,
  });

  final bool isLoading;
  final String? errorMessage;
  final CompanyModel? company;

  CompanyProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    CompanyModel? company,
  }) {
    return CompanyProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      company: company ?? this.company,
    );
  }
}
