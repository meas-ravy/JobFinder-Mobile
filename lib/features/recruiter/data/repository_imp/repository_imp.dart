import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';
import 'package:job_finder/features/recruiter/data/server/recruiter_server.dart';
import 'package:job_finder/features/recruiter/domain/repository/repository.dart';

class RecruiterRepositoryImpl implements RecruiterRepository {
  const RecruiterRepositoryImpl(this._server);

  final RecruiterServer _server;

  @override
  ResultFuture<DataMap> createCompany(DataMap company) {
    return _server.createCompany(CompanyModel.fromJson(company));
  }

  @override
  ResultFuture<DataMap> updateCompany(DataMap company) {
    return _server.updateCompany(company);
  }

  @override
  ResultFuture<DataMap> getCompanyProfile() {
    return _server.getCompanyProfile();
  }
}
