import 'package:bloc/bloc.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/utils/check_connection.dart';
import 'package:flutter/material.dart';

part 'connection_event.dart';
part 'connection_state.dart';

class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final AppConnectionCubit _appConnectionCubit;
  ConnectionBloc(AppConnectionCubit appConnectionCubit)
    : _appConnectionCubit = appConnectionCubit,
      super(ConnectionInitial()) {
    on<CheckConnection>((event, emit) async {
      emit(ConnectionChecking());
      final res = await isConnectedToInternet();
      (res) ? emit(ConnectionSuccessful()) : emit(ConnectionFailed());
      _appConnectionCubit.isConnected(res);
    });
  }
}
