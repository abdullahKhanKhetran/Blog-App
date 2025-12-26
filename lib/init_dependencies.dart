import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/credentials/secrets.dart';
import 'package:blog_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:blog_app/features/auth/data/repositories/auth_respository_impl.dart';
import 'package:blog_app/features/auth/domain/repositories/auth_repositry.dart';
import 'package:blog_app/features/auth/domain/usecases/current_user.dart';
import 'package:blog_app/features/auth/domain/usecases/user_login.dart';
import 'package:blog_app/features/auth/domain/usecases/user_logout.dart';
import 'package:blog_app/features/auth/domain/usecases/user_signup.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/blog/data/data%20sources/blog_data_source.dart';
import 'package:blog_app/features/blog/data/data%20sources/blog_local_data_source.dart';
import 'package:blog_app/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';
import 'package:blog_app/features/blog/domain/usecases/get_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/get_blogs_locally.dart';
import 'package:blog_app/features/blog/domain/usecases/get_my_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/post_blog.dart';
import 'package:blog_app/features/blog/domain/usecases/delete_blog.dart';
import 'package:blog_app/features/blog/domain/usecases/update_blog.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/core/common/bloc/app_connection/bloc/connection_bloc.dart';

// Add these imports
import 'package:blog_app/core/common/utils/init_local_db.dart';
import 'package:sqflite/sqflite.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // Initialize Supabase first
  final supabase = await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.anonKey,
  );

  // Initialize SQLite database
  final database = await openExistingDatabase();
  print("database exists ? : ${database.isOpen}");
  // Register both clients as lazy singletons
  serviceLocator.registerLazySingleton<SupabaseClient>(() => supabase.client);
  serviceLocator.registerLazySingleton<Database>(() => database);

  // Then register other dependencies
  _initAuth();
  _initBlog();
  _initConnection();
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: serviceLocator()),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRespositoryImpl(
        authRemoteDataSource: serviceLocator<AuthRemoteDataSource>(),
      ),
    )
    ..registerFactory<Signup>(
      () => Signup(authRepository: serviceLocator<AuthRepository>()),
    )
    ..registerFactory<Signin>(
      () => Signin(authRepository: serviceLocator<AuthRepository>()),
    )
    ..registerFactory<CurrentUser>(
      () => CurrentUser(authRepository: serviceLocator<AuthRepository>()),
    )
    ..registerFactory<UserLogout>(
      () => UserLogout(authRepository: serviceLocator<AuthRepository>()),
    )
    ..registerLazySingleton(() => AppUserCubit())
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        signupUsecase: serviceLocator<Signup>(),
        signinUsecase: serviceLocator<Signin>(),
        currentUserUsecase: serviceLocator<CurrentUser>(),
        logoutUsecase: serviceLocator<UserLogout>(),
        appUserCubit: serviceLocator<AppUserCubit>(),
      ),
    );
}

void _initBlog() {
  serviceLocator
    ..registerFactory<BlogDataSource>(
      () => BlogDataSourceImpl(supabaseClient: serviceLocator()),
    )
    // Now BlogLocalDataSource takes the database as a parameter
    ..registerLazySingleton<BlogLocalDataSource>(
      () => BlogLocalDataSourceImpl(database: serviceLocator<Database>()),
    )
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        blogDataSource: serviceLocator<BlogDataSource>(),
        blogLocalDataSource: serviceLocator<BlogLocalDataSource>(),
      ),
    )
    ..registerFactory<GetBlogs>(
      () => GetBlogs(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerFactory<PostBlog>(
      () => PostBlog(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerFactory<DeleteBlog>(
      () => DeleteBlog(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerFactory<UpdateBlog>(
      () => UpdateBlog(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerFactory<GetMyBlogs>(
      () => GetMyBlogs(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerFactory<GetBlogsLocally>(
      () => GetBlogsLocally(blogRepository: serviceLocator<BlogRepository>()),
    )
    ..registerLazySingleton<BlogBloc>(
      () => BlogBloc(
        getBlogs: serviceLocator<GetBlogs>(),
        postBlog: serviceLocator<PostBlog>(),
        deleteBlog: serviceLocator<DeleteBlog>(),
        updateBlog: serviceLocator<UpdateBlog>(),
        getMyBlogs: serviceLocator<GetMyBlogs>(),
        getLocalBlogs: serviceLocator<GetBlogsLocally>(),
      ),
    );
}

void _initConnection() {
  serviceLocator
    ..registerLazySingleton<AppConnectionCubit>(() => AppConnectionCubit())
    ..registerLazySingleton<ConnectionBloc>(
      () => ConnectionBloc(serviceLocator<AppConnectionCubit>()),
    );
}
