import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';

enum RecruiterAction { createCompany, getCompanyProfile, updateCompany }

class RecruiterState {
  const RecruiterState({
    this.isLoading = false,
    this.errorMessage,
    this.data,
    this.lastAction,
  });

  final bool isLoading;
  final String? errorMessage;
  final DataMap? data;
  final RecruiterAction? lastAction;

  CompanyModel? get company {
    if (data == null) return null;

    // Check for 'company' key (from some API responses)
    if (data!['company'] is Map<String, dynamic>) {
      return CompanyModel.fromJson(data!['company'] as Map<String, dynamic>);
    }

    // Check for 'data' key (standard project wrapper)
    if (data!['data'] is Map<String, dynamic>) {
      final innerData = data!['data'] as Map<String, dynamic>;
      if (innerData.containsKey('name')) {
        return CompanyModel.fromJson(innerData);
      }
    }

    // Fallback: check if the top level has company-like fields
    if (data!.containsKey('name') && data!.containsKey('contactEmail')) {
      return CompanyModel.fromJson(data!);
    }

    return null;
  }

  RecruiterState copyWith({
    bool? isLoading,
    String? errorMessage,
    DataMap? data,
    RecruiterAction? lastAction,
  }) {
    return RecruiterState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      data: data ?? this.data,
      lastAction: lastAction ?? this.lastAction,
    );
  }
}
