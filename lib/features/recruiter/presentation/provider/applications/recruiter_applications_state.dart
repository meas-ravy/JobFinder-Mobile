import 'package:job_finder/features/recruiter/domain/entity/application_detail_entity.dart';
import 'package:job_finder/features/recruiter/domain/entity/application_entity.dart';

class RecruiterApplicationsState {
  const RecruiterApplicationsState({
    this.isLoading = false,
    this.errorMessage,
    this.applicants = const [],
    this.applicationDetails,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<ApplicationEntity> applicants;
  final ApplicationDetailEntity? applicationDetails;

  RecruiterApplicationsState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<ApplicationEntity>? applicants,
    Object? applicationDetails = const Object(),
  }) {
    return RecruiterApplicationsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      applicants: applicants ?? this.applicants,
      applicationDetails: applicationDetails == const Object()
          ? this.applicationDetails
          : applicationDetails as ApplicationDetailEntity?,
    );
  }
}
