import 'dart:io';

import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBlogParams {
  final String id;
  final String title;
  final String content;
  final String userId;
  final File image;
  const UpdateBlogParams({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.image,
  });
}

class UpdateBlog implements Usecase<BlogModel, UpdateBlogParams> {
  final BlogRepository blogRepository;
  const UpdateBlog({required this.blogRepository});
  @override
  Future<Either<Failure, BlogModel>> call(UpdateBlogParams params) {
    return blogRepository.updateBlog(
      id: params.id,
      title: params.title,
      content: params.content,
      userId: params.userId,
      image: params.image,
    );
  }
}
