import 'package:fpdart/fpdart.dart';
import 'package:blog_app/core/error/faliure.dart';

abstract interface class Usecase<SuccessType, Params> {
  /// The call method is the main entry point for the use case.
  /// It takes in parameters of type [Params] and returns a [Future] that resolves to an [Either] type.
  /// The [Either] type can either be a [Failure] or a successful result of type [SuccessType].
  Future<Either<Failure, SuccessType>> call(Params params);
}
