import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/core/common/params/noparams.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';
import 'package:fpdart/fpdart.dart';
import 'package:blog_app/core/error/faliure.dart';

class UserLogout implements Usecase<Unit, NoParams> {
  final AuthRepository authRepository;

  const UserLogout({required this.authRepository});
  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    return await authRepository.signOut();
  }
}
