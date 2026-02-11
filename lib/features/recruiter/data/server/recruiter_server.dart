import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:job_finder/core/constants/api_enpoint.dart';
import 'package:job_finder/core/helper/error.dart';
import 'package:job_finder/core/helper/error_message.dart';
import 'package:job_finder/core/helper/typedef.dart';
import 'package:job_finder/core/networks/dio_client.dart';
import 'package:job_finder/features/recruiter/data/models/company_model.dart';

abstract class RecruiterServer {
  ResultFuture<DataMap> createCompany(CompanyModel company);
  ResultFuture<DataMap> updateCompany(DataMap company);
  ResultFuture<DataMap> getCompanyProfile();
}

class RecruiterServerImpl implements RecruiterServer {
  final dio = setupAuthenticatedDio(ApiEnpoint.baseUrl);

  @override
  ResultFuture<DataMap> createCompany(CompanyModel company) async {
    try {
      final response = await dio.post(
        ApiEnpoint.company,
        data: company.toJson(),
      );
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> updateCompany(DataMap company) async {
    try {
      final response = await dio.put(ApiEnpoint.company, data: company);
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }

  @override
  ResultFuture<DataMap> getCompanyProfile() async {
    try {
      final response = await dio.get(ApiEnpoint.company);
      final data = response.data;
      if (data is DataMap) {
        return Right(data);
      }
      return Right(<String, dynamic>{'data': data});
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode ?? -1;
      final message = errorMessage(statusCode, e);
      return Left(ApiFailure(message: message, statusCode: statusCode));
    }
  }
}
