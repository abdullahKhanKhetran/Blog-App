part of 'connection_bloc.dart';

@immutable
sealed class ConnectionEvent {}

class CheckConnection extends ConnectionEvent {}
