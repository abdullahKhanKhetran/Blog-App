import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyBlogsScreen extends StatefulWidget {
  const MyBlogsScreen({super.key});

  @override
  State<MyBlogsScreen> createState() => _MyBlogsScreenState();
}

class _MyBlogsScreenState extends State<MyBlogsScreen> {
  @override
  void initState() {
    super.initState();
    if (context.read<AppConnectionCubit>().state is AppConnectionSuccesful) {
      context.read<BlogBloc>().add(
        BlogGetMyBlogs(
          id: (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id,
        ),
      );
    } else {
      context.read<BlogBloc>().add(
        BlogGetBlogsLocally(
          id: (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogBloc, BlogState>(
      builder: (context, state) {
        if (state is BlogLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BlogLoaded && state.blogList!.isNotEmpty) {
          return SafeArea(
            child: ListView.builder(
              itemCount: state.blogList!.length,
              itemBuilder: (context, index) => BlogCard(
                cardColor: (index.isEven)
                    ? AppPallete.gradient1
                    : AppPallete.gradient2,
                blog: state.blogList![index],
              ),
            ),
          );
        } else if (state is BlogLoaded &&
            (state.blogList == null || state.blogList!.isEmpty)) {
          return Center(
            child: Text(
              "NO BLOGS TO SHOW",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppPallete.gradient2),
            ),
          );
        } else if (state is BlogFailure) {
          return Center(
            child: Text(
              "Error: ${state.message}",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: Colors.red),
            ),
          );
        } else {
          return Center(
            child: Text(
              "NO BLOGS TO SHOW",
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: AppPallete.gradient2),
            ),
          );
        }
      },
    );
  }
}
