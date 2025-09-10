import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> getcurrentUserData();
  Future<Either<Failure, Unit>> signOut(); // Optional, can be added
  // Optional, can be overridden if needed
}
