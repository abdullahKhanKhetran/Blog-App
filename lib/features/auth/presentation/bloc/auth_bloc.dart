import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/params/signnin_params.dart';
import 'package:blog_app/core/common/params/Signup_params.dart';
import 'package:blog_app/core/common/params/noparams.dart';
import 'package:blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app/features/auth/domain/usecases/user_logout.dart';
import 'package:blog_app/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Signup _signupUsecase;
  final Signin _signinUsecase;
  final CurrentUser _currentUserUsecase;
  final UserLogout _logoutUsecase;
  final AppUserCubit _appUserCubit;
  // final Signin _signinUsecase;
  AuthBloc({
    required Signup signupUsecase,
    required Signin signinUsecase,
    required CurrentUser currentUserUsecase,
    required UserLogout logoutUsecase,
    required AppUserCubit appUserCubit,
  }) : _signupUsecase = signupUsecase,
       _signinUsecase = signinUsecase,
       _currentUserUsecase = currentUserUsecase,
       _logoutUsecase = logoutUsecase,
       _appUserCubit = appUserCubit,
       super(AuthInitial()) {
    // on<AuthEvent>((_, emit) => AuthLoading);
    on<AuthSignOut>(_AuthSignOut);
    on<AuthIsUserLoggedIn>(_AuthIsUserLoggedIn);
    on<AuthSignIn>(_AuthSignIn);
    on<AuthSignUp>(_AuthSignUp);
  }
  // ignore: non_constant_identifier_names
  void _AuthSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _logoutUsecase(NoParams());
    res.fold((l) => emit(AuthFailure(message: l.message)), (r) {
      emit(AuthLogOutSuccess());
      _appUserCubit.updateUser(null);
      print("User logged out successfully");
    });
  }

  void _AuthIsUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    print("Checking if user is logged in...");
    final res = await _currentUserUsecase(NoParams());
    res.fold(
      (l) {
        _appUserCubit.updateUser(null);
        emit(AuthFailure(message: l.message));
      },
      (r) {
        print(r.name);
        emit(AuthLoggedInSuccess());
        _appUserCubit.updateUser(r);
      },
    );
  }

  void _AuthSignIn(AuthSignIn event, emit) async {
    print("Signing in...");
    emit(AuthLoading());
    final res = await _signinUsecase(
      UserSigninParams(email: event.email, password: event.password),
    );

    res.fold((l) => emit(AuthFailure(message: l.message)), (r) {
      print("user found");
      emit(AuthLogInSuccess());
      _appUserCubit.updateUser(r);
    });
  }

  void _AuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final res = await _signupUsecase(
      UserSignupParams(
        email: event.email,
        name: event.name,
        password: event.password,
      ),
    );
    res.fold((l) => emit(AuthFailure(message: l.message)), (r) {
      emit(AuthSignUpSuccess());
    });
  }
}
