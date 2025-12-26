part of 'connection_bloc.dart';

@immutable
sealed class ConnectionEvent {}

class CheckConnection extends ConnectionEvent {}

class StartPeriodicCheck extends ConnectionEvent {}

class StopPeriodicCheck extends ConnectionEvent {}