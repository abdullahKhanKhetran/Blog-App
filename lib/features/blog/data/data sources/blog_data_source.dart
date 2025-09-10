import 'dart:io';

import 'package:blog_app/core/error/server_exception.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogDataSource {
  Future<List<BlogModel>> getMyBlogs({required userId});
  Future<List<Map<String, dynamic>>> getBlogs(String userId);
  Future<Map<String, dynamic>> postBlog({required BlogModel blog});
  Future<String> uploadImage({required File image, required BlogModel blog});
  Future<String> deleteImage({required String id});
  Future<BlogModel> deleteBlog({required String id});
  Future<BlogModel> editBlog({required BlogModel blog});
  Future<String> updateImage({required File image, required BlogModel blog});
}

class BlogDataSourceImpl implements BlogDataSource {
  final SupabaseClient supabaseClient;
  const BlogDataSourceImpl({required this.supabaseClient});
  // ... existing code ...
  @override
  Future<Map<String, dynamic>> postBlog({required BlogModel blog}) async {
    try {
      final response = await supabaseClient
          .from('blogs')
          .insert(blog.toJson())
          .select(); // Add this to return the inserted data

      return response.first; // Return the first (and only) inserted row
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ... existing code ...
  @override
  Future<List<Map<String, dynamic>>> getBlogs(String userId) async {
    try {
      final response = await supabaseClient
          .from('blogs')
          .select('*,profiles(name)')
          .neq('user_id', userId);
      // Return empty list instead of throwing exception for no blogs
      return response;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> uploadImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      await supabaseClient.storage.from('blog_images').upload(blog.id, image);
      return await supabaseClient.storage
          .from('blog_images')
          .getPublicUrl(blog.id);
    } catch (e) {
      print(e.toString());
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BlogModel> deleteBlog({required String id}) async {
    try {
      final deletedBlog = await supabaseClient
          .from('blogs')
          .delete()
          .eq('id', id)
          .select();
      return BlogModel.fromJson(deletedBlog.first);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> deleteImage({required String id}) async {
    try {
      final imageUrl = await supabaseClient.storage.from('blog_images').remove([
        id,
      ]);
      if (imageUrl.isNotEmpty) {
        print(imageUrl.first.id!);
        return imageUrl.first.id!;
      } else {
        return "";
      }
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<BlogModel> editBlog({required BlogModel blog}) async {
    try {
      final updatedblog = await supabaseClient
          .from("blogs")
          .update(blog.toJson())
          .eq('id', blog.id)
          .select();
      return BlogModel.fromJson(updatedblog.first);
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<String> updateImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      await supabaseClient.storage.from('blog_images').update(blog.id, image);
      final imageUrl = supabaseClient.storage
          .from('blog_images')
          .getPublicUrl(blog.id);
      return imageUrl;
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<BlogModel>> getMyBlogs({required userId}) async {
    try {
      final blogs = await supabaseClient
          .from('blogs')
          .select('*,profiles(name)')
          .eq('user_id', userId);
      return List.generate(
        blogs.length,
        (index) => BlogModel.fromJson(
          blogs[index],
        ).copyWith(name: blogs[index]['profiles']['name']),
      );
    } on Exception catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
