import 'dart:io';

import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, List<Blog>>> getBlogsLocally(String userId);
  Future<Either<Failure, List<Blog>>> getblogs(String userId);
  Future<Either<Failure, BlogModel>> postBlog({
    required String title,
    required String content,
    required String userId,
    required File image,
  });
  Future<Either<Failure, BlogModel>> updateBlog({
    required String id,
    required String title,
    required String content,
    required String userId,
    required File image,
  });
  Future<Either<Failure, Blog>> deleteBlog({required String id});
  Future<Either<Failure, List<Blog>>> getMyBlogs(String userId);
}
