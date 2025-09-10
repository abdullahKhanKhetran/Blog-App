import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/bloc/bloc/connection_bloc.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_card.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  @override
  void initState() {
    context.read<BlogBloc>().add(
      BlogLoadBlogs(
        id: (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        return (state is ConnectionChecking)
            ? const Loader()
            : (state is ConnectionFailed)
            ? Center(child: Text("You are offline"))
            : BlocBuilder<BlogBloc, BlogState>(
                builder: (context, state) {
                  if (state is BlogLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BlogLoaded &&
                      state.blogList!.isNotEmpty) {
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppPallete.gradient2,
                        ),
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppPallete.gradient2,
                        ),
                      ),
                    );
                  }
                },
              );
      },
    );
  }
}
