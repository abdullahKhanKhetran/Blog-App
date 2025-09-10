import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:blog_app/core/common/params/noparams.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository authRepository;
  const CurrentUser({required this.authRepository});

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.getcurrentUserData();
  }
}
