import 'package:job_finder/core/helper/typedef.dart';

// ignore: avoid_types_as_parameter_names
abstract class UseCaseWithOutParams<Type> {
  const UseCaseWithOutParams();
  ResultFuture<Type> call();
}

// ignore: avoid_types_as_parameter_names
abstract class UseCaseWithParams<Type, param> {
  const UseCaseWithParams();
  ResultFuture<Type> call(param param);
}
