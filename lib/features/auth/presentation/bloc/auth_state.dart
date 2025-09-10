part of 'auth_bloc.dart';

@immutable
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthFailure extends AuthState {
  final String? message;

  const AuthFailure({this.message});
}

final class AuthSuccess extends AuthState {}

final class AuthLogOutSuccess extends AuthState {}

final class AuthLogInSuccess extends AuthState {}

final class AuthLoggedInSuccess extends AuthState {}

final class AuthSignUpSuccess extends AuthState {}
