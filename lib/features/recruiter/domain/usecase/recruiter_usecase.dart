import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/helper/usecase.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';

class CreateCompanyParams {
  const CreateCompanyParams({required this.company});
  final DataMap company;
}

class CreateCompanyUseCase
    extends UseCaseWithParams<DataMap, CreateCompanyParams> {
  const CreateCompanyUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(CreateCompanyParams params) {
    return _repository.createCompany(params.company);
  }
}

class GetCompanyProfileUseCase extends UseCaseWithOutParams<DataMap> {
  const GetCompanyProfileUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call() {
    return _repository.getCompanyProfile();
  }
}

class UpdateCompanyParams {
  const UpdateCompanyParams({required this.company});
  final DataMap company;
}

class UpdateCompanyUseCase
    extends UseCaseWithParams<DataMap, UpdateCompanyParams> {
  const UpdateCompanyUseCase(this._repository);
  final RecruiterRepository _repository;

  @override
  ResultFuture<DataMap> call(UpdateCompanyParams params) {
    return _repository.updateCompany(params.company);
  }
}
