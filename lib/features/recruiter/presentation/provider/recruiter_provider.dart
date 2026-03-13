import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/data/repository_imp/repository_imp.dart';
import 'package:job_finder/features/recruiter/data/server/recruiter_server.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/jobs/recruiter_jobs_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/jobs/recruiter_jobs_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/applications/recruiter_applications_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/applications/recruiter_applications_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/dashboard/recruiter_dashboard_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/dashboard/recruiter_dashboard_state.dart';
import 'package:job_finder/features/recruiter/presentation/provider/conversations/recruiter_conversations_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/conversations/recruiter_conversations_state.dart';

final recruiterServerProvider = Provider<RecruiterServer>((ref) {
  return RecruiterServerImpl();
});

final recruiterRepositoryProvider = Provider<RecruiterRepository>((ref) {
  return RecruiterRepositoryImpl(ref.watch(recruiterServerProvider));
});

final createCompanyUseCaseProvider = Provider<CreateCompanyUseCase>((ref) {
  return CreateCompanyUseCase(ref.watch(recruiterRepositoryProvider));
});

final getCompanyProfileUseCaseProvider = Provider<GetCompanyProfileUseCase>((
  ref,
) {
  return GetCompanyProfileUseCase(ref.watch(recruiterRepositoryProvider));
});

final updateCompanyUseCaseProvider = Provider<UpdateCompanyUseCase>((ref) {
  return UpdateCompanyUseCase(ref.watch(recruiterRepositoryProvider));
});

final createJobUseCaseProvider = Provider<CreateJobUseCase>((ref) {
  return CreateJobUseCase(ref.watch(recruiterRepositoryProvider));
});

final submitJobUseCaseProvider = Provider<SubmitJobUseCase>((ref) {
  return SubmitJobUseCase(ref.watch(recruiterRepositoryProvider));
});

final getJobsUseCaseProvider = Provider<GetJobsUseCase>((ref) {
  return GetJobsUseCase(ref.watch(recruiterRepositoryProvider));
});

final updateJobStatusUseCaseProvider = Provider<UpdateJobStatusUseCase>((ref) {
  return UpdateJobStatusUseCase(ref.watch(recruiterRepositoryProvider));
});

final updateJobUseCaseProvider = Provider<UpdateJobUseCase>((ref) {
  return UpdateJobUseCase(ref.watch(recruiterRepositoryProvider));
});

final deleteJobUseCaseProvider = Provider<DeleteJobUseCase>((ref) {
  return DeleteJobUseCase(ref.watch(recruiterRepositoryProvider));
});

final getJobApplicationsUseCaseProvider = Provider<GetJobApplicationsUseCase>((
  ref,
) {
  return GetJobApplicationsUseCase(ref.watch(recruiterRepositoryProvider));
});

final getAllApplicationsUseCaseProvider = Provider<GetAllApplicationsUseCase>((
  ref,
) {
  return GetAllApplicationsUseCase(ref.watch(recruiterRepositoryProvider));
});

final getApplicationDetailsUseCaseProvider =
    Provider<GetApplicationDetailsUseCase>((ref) {
      return GetApplicationDetailsUseCase(
        ref.watch(recruiterRepositoryProvider),
      );
    });

final updateApplicationStatusUseCaseProvider =
    Provider<UpdateApplicationStatusUseCase>((ref) {
      return UpdateApplicationStatusUseCase(
        ref.watch(recruiterRepositoryProvider),
      );
    });

final getRecruiterDashboardUseCaseProvider =
    Provider<GetRecruiterDashboardUseCase>((ref) {
      return GetRecruiterDashboardUseCase(
        ref.watch(recruiterRepositoryProvider),
      );
    });

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((
  ref,
) {
  return GetConversationsUseCase(ref.watch(recruiterRepositoryProvider));
});

final updateConversationUseCaseProvider = Provider<UpdateConversationUseCase>((
  ref,
) {
  return UpdateConversationUseCase(ref.watch(recruiterRepositoryProvider));
});

// --- NEW SPECIALIZED CONTROLLERS ---

final recruiterJobsControllerProvider =
    StateNotifierProvider<RecruiterJobsController, RecruiterJobsState>((ref) {
      return RecruiterJobsController(
        createJobUseCase: ref.watch(createJobUseCaseProvider),
        submitJobUseCase: ref.watch(submitJobUseCaseProvider),
        getJobsUseCase: ref.watch(getJobsUseCaseProvider),
        updateJobStatusUseCase: ref.watch(updateJobStatusUseCaseProvider),
        updateJobUseCase: ref.watch(updateJobUseCaseProvider),
        deleteJobUseCase: ref.watch(deleteJobUseCaseProvider),
      );
    });

final recruiterApplicationsControllerProvider =
    StateNotifierProvider<
      RecruiterApplicationsController,
      RecruiterApplicationsState
    >((ref) {
      return RecruiterApplicationsController(
        getJobApplicationsUseCase: ref.watch(getJobApplicationsUseCaseProvider),
        getAllApplicationsUseCase: ref.watch(getAllApplicationsUseCaseProvider),
        getApplicationDetailsUseCase: ref.watch(
          getApplicationDetailsUseCaseProvider,
        ),
        updateApplicationStatusUseCase: ref.watch(
          updateApplicationStatusUseCaseProvider,
        ),
      );
    });

final recruiterDashboardControllerProvider =
    StateNotifierProvider<
      RecruiterDashboardController,
      RecruiterDashboardState
    >((ref) {
      return RecruiterDashboardController(
        getRecruiterDashboardUseCase: ref.watch(
          getRecruiterDashboardUseCaseProvider,
        ),
      );
    });

final recruiterConversationsControllerProvider =
    StateNotifierProvider<
      RecruiterConversationsController,
      RecruiterConversationsState
    >((ref) {
      return RecruiterConversationsController(
        getConversationsUseCase: ref.watch(getConversationsUseCaseProvider),
        updateConversationUseCase: ref.watch(updateConversationUseCaseProvider),
      );
    });

final recruiterHomeTabProvider = StateProvider<int>((ref) => 0);
