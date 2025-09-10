part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

class BlogLoadBlogs extends BlogEvent {
  final String id;

  BlogLoadBlogs({required this.id});
}

class BlogPostBlog extends BlogEvent {
  final String title;
  final String content;
  final String userId;
  final File image;
  BlogPostBlog({
    required this.title,
    required this.content,
    required this.userId,
    required this.image,
  });
}

class BlogDeleteBlog extends BlogEvent {
  final String id;
  final String userId;
  BlogDeleteBlog({required this.userId, required this.id});
}

class BlogGetBlogsLocally extends BlogEvent {
  final String id;
  BlogGetBlogsLocally({required this.id});
}

class BlogGetMyBlogs extends BlogEvent {
  final String id;

  BlogGetMyBlogs({required this.id});
}

class BlogUpdateBlog extends BlogEvent {
  final String id;
  final String title;
  final String content;
  final String userId;
  final File image;
  BlogUpdateBlog({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.image,
  });
}
