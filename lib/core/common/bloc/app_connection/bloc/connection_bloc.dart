import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/utils/check_connection.dart';
import 'package:flutter/material.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final AppConnectionCubit _appConnectionCubit;
  Timer? _periodicCheck;
  bool _isChecking = false;

  ConnectionBloc(AppConnectionCubit appConnectionCubit)
      : _appConnectionCubit = appConnectionCubit,
        super(ConnectionInitial()) {
    on<CheckConnection>(_onCheckConnection);
    on<StartPeriodicCheck>(_onStartPeriodicCheck);
    on<StopPeriodicCheck>(_onStopPeriodicCheck);
  }

  Future<void> _onCheckConnection(
    CheckConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    // Prevent concurrent checks
    if (_isChecking) return;

    _isChecking = true;
    emit(ConnectionChecking());

    try {
      final res = await isConnectedToInternet();
      if (res) {
        emit(ConnectionSuccessful());
      } else {
        emit(ConnectionFailed());
      }
      _appConnectionCubit.isConnected(res);
    } catch (e) {
      emit(ConnectionFailed());
      _appConnectionCubit.isConnected(false);
    } finally {
      _isChecking = false;
    }
  }

  void _onStartPeriodicCheck(
    StartPeriodicCheck event,
    Emitter<ConnectionState> emit,
  ) {
    _periodicCheck?.cancel();
    _periodicCheck = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(CheckConnection()),
    );
  }

  void _onStopPeriodicCheck(
    StopPeriodicCheck event,
    Emitter<ConnectionState> emit,
  ) {
    _periodicCheck?.cancel();
    _periodicCheck = null;
  }

  @override
  Future<void> close() {
    _periodicCheck?.cancel();
    return super.close();
  }
}