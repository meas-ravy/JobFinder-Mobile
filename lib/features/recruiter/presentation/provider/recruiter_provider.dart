import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:job_finder/features/recruiter/data/repository_imp/repository_imp.dart';
import 'package:job_finder/features/recruiter/data/server/recruiter_server.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';
import 'package:job_finder/features/recruiter/domain/usecase/recruiter_usecase.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_controller.dart';
import 'package:job_finder/features/recruiter/presentation/provider/recruiter_state.dart';

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

final recruiterControllerProvider =
    StateNotifierProvider<RecruiterController, RecruiterState>((ref) {
      return RecruiterController(
        createCompanyUseCase: ref.watch(createCompanyUseCaseProvider),
        getCompanyProfileUseCase: ref.watch(getCompanyProfileUseCaseProvider),
        updateCompanyUseCase: ref.watch(updateCompanyUseCaseProvider),
      );
    });
