import 'dart:io';

import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/error/server_exception.dart';
import 'package:blog_app/features/blog/data/data%20sources/blog_data_source.dart';
import 'package:blog_app/features/blog/data/data%20sources/blog_local_data_source.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';

import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogDataSource blogDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  const BlogRepositoryImpl({
    required this.blogDataSource,
    required this.blogLocalDataSource,
  });

  @override
  Future<Either<Failure, List<Blog>>> getblogs(String userId) async {
    try {
      final result = await blogDataSource.getBlogs(userId);
      return right(
        List.generate(result.length, (index) {
          return BlogModel.fromJson(
            result[index],
          ).copyWith(name: result[index]['profiles']['name']);
        }),
      );
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, BlogModel>> postBlog({
    required String title,
    required String content,
    required String userId,
    required File image,
  }) async {
    try {
      BlogModel blog = BlogModel(
        id: const Uuid().v1(),
        title: title,
        content: content,
        userId: userId,
        createdAt: null,
        updatedAt: null,
        imageUrl: "",
      );

      // Remote: upload image and create blog
      final imageUrl = await blogDataSource.uploadImage(
        blog: blog,
        image: image,
      );
      blog = blog.copyWith(imageUrl: imageUrl);
      final result = await blogDataSource.postBlog(blog: blog);
      final remoteCreated = BlogModel.fromJson(result);

      // Local: persist blog directly (image stored as BLOB in blogs table)
      try {
        print(
          '[BlogRepo] Attempting to save blog locally: ${remoteCreated.id}',
        );
        final localResult = await blogLocalDataSource.postBlog(
          blog: remoteCreated,
          image: image,
        );
        print('[BlogRepo] Local save successful: ${localResult['id']}');
      } catch (e) {
        // Log the error but don't fail the entire operation
        print('[BlogRepo] Local save failed: $e');
        // You might want to add retry logic or queue for later sync
      }

      return right(remoteCreated);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Blog>> deleteBlog({required String id}) async {
    try {
      // Remote: delete db row and image
      final deleted = await blogDataSource.deleteBlog(id: id);
      try {
        await blogDataSource.deleteImage(id: id);
      } catch (e) {
        print('[BlogRepo] Image deletion failed: $e');
      }

      // Local: mirror deletion
      try {
        print('[BlogRepo] Attempting to delete blog locally: $id');
        await blogLocalDataSource.deleteBlog(id: id);
        print('[BlogRepo] Local deletion successful');
      } catch (e) {
        print('[BlogRepo] Local deletion failed: $e');
      }

      return right(deleted);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, BlogModel>> updateBlog({
    required String id,
    required String title,
    required String content,
    required String userId,
    required File image,
  }) async {
    try {
      // prepare model
      BlogModel blog = BlogModel(
        id: id,
        title: title,
        content: content,
        userId: userId,
        createdAt: null,
        updatedAt: null,
        imageUrl: "",
      );

      // Remote: update image and blog
      final imageUrl = await blogDataSource.updateImage(
        image: image,
        blog: blog,
      );
      blog = blog.copyWith(imageUrl: imageUrl);
      final updated = await blogDataSource.editBlog(blog: blog);

      // Local: mirror update
      try {
        print('[BlogRepo] Attempting to update blog locally: ${updated.id}');
        await blogLocalDataSource.editBlog(blog: updated, image: image);
        print('[BlogRepo] Local update successful');
      } catch (e) {
        print('[BlogRepo] Local update failed: $e');
      }

      return right(updated);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getMyBlogs(String userId) async {
    try {
      final myBlogs = await blogDataSource.getMyBlogs(userId: userId);
      return (myBlogs.isNotEmpty)
          ? right(myBlogs)
          : left(Failure(message: "NO BLOGS TO SHOW"));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getBlogsLocally(String userId) async {
    try {
      final myBlogs = await blogLocalDataSource.getMyBlogs(userId: userId);
      return (myBlogs.isNotEmpty)
          ? right(myBlogs)
          : left(Failure(message: "NO BLOGS TO SHOW"));
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    }
  }
}
