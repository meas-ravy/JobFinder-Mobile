import 'package:job_finder/core/helper/typedef.dart';

abstract class RecruiterRepository {
  ResultFuture<DataMap> createCompany(DataMap company);
  ResultFuture<DataMap> updateCompany(DataMap company);
  ResultFuture<DataMap> getCompanyProfile();
}
