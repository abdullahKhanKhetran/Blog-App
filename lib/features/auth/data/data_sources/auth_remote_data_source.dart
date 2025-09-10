import 'package:blog_app/core/error/server_exception.dart';
import 'package:blog_app/features/auth/data/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<UserModel> signIn({required String email, required String password});
  Session? get currentUserSession;
  Future<UserModel?> getcurrentUserData();
  Future<Unit> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
        data: {'name': name},
      );
      if (response.user == null) {
        throw ServerException(message: "User not created");
      } else {
        return UserModel.fromJson(response.user!.toJson());
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw ServerException(message: "User not found");
      } else {
        print("USER LOGGED IN");
        try {
          final userdata = await supabaseClient
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .single();
          return UserModel.fromJson(userdata);
        } catch (e) {
          throw ServerException(message: e.toString());
        }
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getcurrentUserData() async {
    try {
      if (currentUserSession != null) {
        final userdata = await supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUserSession!.user.id)
            .single();
        return UserModel.fromJson(userdata);
      }
      return null;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Unit> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      return unit;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
