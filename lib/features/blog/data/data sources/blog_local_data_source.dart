import 'dart:io';
import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/common/utils/get_binary_object.dart';
import 'package:blog_app/core/error/server_exception.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

abstract interface class BlogLocalDataSource {
  Future<List<Blog>> getMyBlogs({required String userId});
  Future<Map<String, dynamic>> postBlog({
    required Blog blog,
    required File image,
  });
  Future<Blog> deleteBlog({required String id});
  Future<Blog> editBlog({required Blog blog, required File image});
}

class BlogLocalDataSourceImpl implements BlogLocalDataSource {
  final Database database;
  final Uuid uuid = Uuid();

  // Inject database through constructor
  BlogLocalDataSourceImpl({required this.database});

  @override
  Future<List<Blog>> getMyBlogs({required String userId}) async {
    try {
      print('[LocalDB] Getting blogs for user: $userId');
      final List<Map<String, dynamic>> blogs = await database.query(
        'blogs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      print('[LocalDB] Found ${blogs.length} blogs');
      return blogs.map((blog) => _mapToBlog(blog)).toList();
    } catch (e) {
      print('[LocalDB] Error getting blogs: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> postBlog({
    required Blog blog,
    required File image,
  }) async {
    try {
      print('[LocalDB] Attempting to save blog: ${blog.id}');
      print('[LocalDB] Blog title: ${blog.title}');
      print('[LocalDB] User ID: ${blog.userId}');

      // Check if file exists and can be read
      if (!await image.exists()) {
        throw Exception('Image file does not exist: ${image.path}');
      }

      final imageBytes = await fileToBlob(image);
      print('[LocalDB] Image converted to bytes: ${imageBytes.length} bytes');

      // Check if database is accessible
      final tables = await database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'",
      );
      print(
        '[LocalDB] Available tables: ${tables.map((t) => t['name']).join(', ')}',
      );

      // Check existing table structure
      final tableInfo = await database.rawQuery("PRAGMA table_info(blogs)");
      print(
        '[LocalDB] Blogs table columns: ${tableInfo.map((col) => col['type']).join(', ')}',
      );

      final blogData = {
        'id': blog.id,
        'title': blog.title,
        'content': blog.content,
        'user_id': blog.userId,
        'image_url': blog.imageUrl,
        'name': blog.name,
        'created_at':
            blog.createdAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'updated_at':
            blog.updatedAt?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        'image': imageBytes,
      };

      print('[LocalDB] Prepared blog data keys: ${blogData.keys.join(', ')}');

      final insertResult = await database.insert(
        'blogs',
        blogData,
        conflictAlgorithm: ConflictAlgorithm.replace, // Handle duplicates
      );

      print('[LocalDB] Blog inserted successfully with row id: $insertResult');

      // Verify the insertion by querying back
      final verification = await database.query(
        'blogs',
        where: 'id = ?',
        whereArgs: [blog.id],
      );

      if (verification.isEmpty) {
        throw Exception('Blog was not actually inserted into database');
      }

      print('[LocalDB] Verification successful: blog exists in database');
      blogData['row_id'] = insertResult;
      return blogData;
    } catch (e) {
      print('[LocalDB] Error saving blog: $e');
      print('[LocalDB] Stack trace: ${StackTrace.current}');
      throw ServerException(message: 'Failed to save blog locally: $e');
    }
  }

  @override
  Future<Blog> deleteBlog({required String id}) async {
    try {
      print('[LocalDB] Attempting to delete blog: $id');

      // First get the blog to return it
      final List<Map<String, dynamic>> blogs = await database.query(
        'blogs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (blogs.isEmpty) {
        throw ServerException(message: 'Blog not found with id: $id');
      }

      final blog = _mapToBlog(blogs.first);
      print('[LocalDB] Found blog to delete: ${blog.title}');

      // Delete the blog
      final deletedRows = await database.delete(
        'blogs',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (deletedRows == 0) {
        throw ServerException(message: 'No blog was deleted');
      }

      print('[LocalDB] Blog deleted successfully');
      return blog;
    } catch (e) {
      print('[LocalDB] Error deleting blog: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Blog> editBlog({required Blog blog, required File image}) async {
    try {
      print('[LocalDB] Attempting to edit blog: ${blog.id}');

      if (!await image.exists()) {
        throw Exception('Image file does not exist: ${image.path}');
      }

      final imageBytes = await fileToBlob(image);

      final blogData = {
        'title': blog.title,
        'content': blog.content,
        'image_url': blog.imageUrl,
        'name': blog.name,
        'updated_at': DateTime.now().toIso8601String(),
        'image': imageBytes,
      };

      final updatedRows = await database.update(
        'blogs',
        blogData,
        where: 'id = ?',
        whereArgs: [blog.id],
      );

      if (updatedRows == 0) {
        throw ServerException(
          message: "No blog was updated - blog with id ${blog.id} not found",
        );
      }

      print('[LocalDB] Blog updated successfully');
      return blog;
    } catch (e) {
      print('[LocalDB] Error editing blog: $e');
      throw ServerException(message: e.toString());
    }
  }

  Blog _mapToBlog(Map<String, dynamic> map) {
    return Blog(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      userId: map['user_id'] ?? '',
      imageUrl: map['image_url'] ?? '',
      name: map['name'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
      image: map['image'],
    );
  }

  // Add method to check database health
  Future<void> checkDatabaseHealth() async {
    try {
      final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM blogs',
      );
      print(
        '[LocalDB] Database health check: ${result.first['count']} blogs in database',
      );

      // Also check database path
      print('[LocalDB] Database path: ${database.path}');
    } catch (e) {
      print('[LocalDB] Database health check failed: $e');
    }
  }
}
