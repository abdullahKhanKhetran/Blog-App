import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/error/server_exception.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';
import 'package:fpdart/fpdart.dart';
import 'package:blog_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AuthRespositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  const AuthRespositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return await _getUser(
      () async => authRemoteDataSource.signUp(
        email: email,
        password: password,
        name: name,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    return await _getUser(
      () async => authRemoteDataSource.signIn(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, User>> getcurrentUserData() async {
    try {
      final user = await authRemoteDataSource.getcurrentUserData();
      if (user != null) {
        return Right(user);
      } else {
        return Left(Failure(message: "No user data found"));
      }
    } on sb.AuthException catch (e) {
      return Left(Failure(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await authRemoteDataSource.signOut();
      return Right(unit);
    } on ServerException catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}

Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
  try {
    final user = await fn();
    return Right(user);
  } on sb.AuthException catch (e) {
    return Left(Failure(message: e.message));
  } on ServerException catch (e) {
    return Left(Failure(message: e.message));
  }
}
