import 'package:bloc/bloc.dart';
import 'package:blog_app/core/common/entities/user.dart';
import 'package:flutter/foundation.dart';
part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());
  void updateUser(User? user) {
    if (user == null) {
      print("User logged out");
      emit(AppUserLoggedOut());
      return;
    } else {
      print("User logged in: ${user.name.toString()}");
      emit(AppUserLoggedIn(user: user));
    }
  }
}
