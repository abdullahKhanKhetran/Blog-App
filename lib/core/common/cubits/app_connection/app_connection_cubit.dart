import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

part 'app_connection_state.dart';

class AppConnectionCubit extends Cubit<AppConnectionState> {
  AppConnectionCubit() : super(AppConnectionInitial());

  void isConnected(bool isConnected) {
    if (isConnected) {
      print("is online");
      emit(AppConnectionSuccesful());
    } else {
      print("is offline");
      emit(AppConnectionInitial());
    }
  }
}
