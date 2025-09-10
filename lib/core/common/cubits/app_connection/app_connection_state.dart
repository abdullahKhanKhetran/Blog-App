part of 'app_connection_cubit.dart';

@immutable
sealed class AppConnectionState {}

final class AppConnectionInitial extends AppConnectionState {}

final class AppConnectionSuccesful extends AppConnectionState {}
