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
  ResultFuture<DataMap> createJob(DataMap job);
  ResultFuture<DataMap> submitJob(String jobId);
  ResultFuture<DataMap> getJobs({String? status});
  ResultFuture<DataMap> updateJobStatus(String jobId, String status);
  ResultFuture<DataMap> updateJob(String jobId, DataMap job);
  ResultFuture<DataMap> deleteJob(String jobId);
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

  @override
  ResultFuture<DataMap> createJob(DataMap job) async {
    try {
      final response = await dio.post(ApiEnpoint.jobs, data: job);
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
  ResultFuture<DataMap> submitJob(String jobId) async {
    try {
      final response = await dio.patch(ApiEnpoint.submitJob(jobId));
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
  ResultFuture<DataMap> getJobs({String? status}) async {
    try {
      final response = await dio.get(
        ApiEnpoint.jobs,
        queryParameters: status != null ? {'status': status} : null,
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
  ResultFuture<DataMap> updateJobStatus(String jobId, String status) async {
    try {
      final response = await dio.patch(
        ApiEnpoint.updateJobStatus(jobId),
        data: {'status': status},
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
  ResultFuture<DataMap> updateJob(String jobId, DataMap job) async {
    try {
      final response = await dio.put(ApiEnpoint.updateJob(jobId), data: job);
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
  ResultFuture<DataMap> deleteJob(String jobId) async {
    try {
      final response = await dio.delete(ApiEnpoint.deleteJob(jobId));
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
