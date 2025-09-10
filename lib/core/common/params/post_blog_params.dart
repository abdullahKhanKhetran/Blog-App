import 'dart:io';

class PostBlogParams {
  final String title;
  final String content;
  final String userId;
  final File image;
  const PostBlogParams({
    required this.content,
    required this.title,
    required this.userId,
    required this.image,
  });
}
