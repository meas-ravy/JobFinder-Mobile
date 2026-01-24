import 'package:dartz/dartz.dart';
import 'package:job_finder/core/helper/error.dart';

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef DataMap = Map<String, dynamic>;
typedef ResultVoid = Future<void>;
