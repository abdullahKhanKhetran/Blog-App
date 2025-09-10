import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/common/params/Signup_params.dart';
import 'package:fpdart/fpdart.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';

class Signup implements Usecase<User, UserSignupParams> {
  final AuthRepository authRepository;
  const Signup({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(UserSignupParams params) async {
    return await authRepository.signUp(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}
