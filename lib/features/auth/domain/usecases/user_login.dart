import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/common/params/signnin_params.dart';
import 'package:fpdart/fpdart.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';

class Signin implements Usecase<User, UserSigninParams> {
  final AuthRepository authRepository;
  const Signin({required this.authRepository});
  @override
  Future<Either<Failure, User>> call(UserSigninParams params) async {
    return await authRepository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
