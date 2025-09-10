part of 'blog_bloc.dart';

@immutable
sealed class BlogState {}

final class BlogInitial extends BlogState {}

final class BlogLoading extends BlogState {}

final class BlogLoaded extends BlogState {
  final List<Blog>? blogList;
  BlogLoaded({required this.blogList});
}

final class BlogFailure extends BlogState {
  final String message;
  BlogFailure({required this.message});
}

final class BlogPosted extends BlogState {
  final String status;
  BlogPosted({required this.status});
}

final class BlogDeleted extends BlogState {
  final Blog blog;
  BlogDeleted({required this.blog});
}

final class BlogUpdated extends BlogState {
  final Blog blog;
  BlogUpdated({required this.blog});
}
