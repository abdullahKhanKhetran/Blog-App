part of 'connection_bloc.dart';

@immutable
sealed class ConnectionState {}

final class ConnectionInitial extends ConnectionState {}

final class ConnectionSuccessful extends ConnectionState {}

final class ConnectionFailed extends ConnectionState {}

final class ConnectionChecking extends ConnectionState {}
