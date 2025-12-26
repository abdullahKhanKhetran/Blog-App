import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:blog_app/core/common/params/get_blogs_params.dart';
import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/common/params/post_blog_params.dart';
import 'package:blog_app/features/blog/domain/usecases/get_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/get_blogs_locally.dart';
import 'package:blog_app/features/blog/domain/usecases/get_my_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/post_blog.dart';
import 'package:blog_app/features/blog/domain/usecases/delete_blog.dart';
import 'package:blog_app/features/blog/domain/usecases/update_blog.dart';
import 'package:flutter/material.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final GetBlogs _getBlogsCase;
  final PostBlog _postBlogCase;
  final DeleteBlog _deleteBlogCase;
  final UpdateBlog _updateBlogCase;
  final GetMyBlogs _getMyBlogsCase;
  final GetBlogsLocally _getBlogsLocallyCase;

  // Cache to prevent unnecessary reloads
  List<Blog>? _cachedBlogs;
  String? _lastUserId;

  BlogBloc({
    required GetBlogsLocally getLocalBlogs,
    required GetBlogs getBlogs,
    required PostBlog postBlog,
    required DeleteBlog deleteBlog,
    required UpdateBlog updateBlog,
    required GetMyBlogs getMyBlogs,
  }) : _getBlogsLocallyCase = getLocalBlogs,
       _getBlogsCase = getBlogs,
       _postBlogCase = postBlog,
       _deleteBlogCase = deleteBlog,
       _updateBlogCase = updateBlog,
       _getMyBlogsCase = getMyBlogs,
       super(BlogInitial()) {
    on<BlogLoadBlogs>(_loadBlogs);
    on<BlogPostBlog>(_postBlog);
    on<BlogDeleteBlog>(_deleteBlog);
    on<BlogUpdateBlog>(_updateBlog);
    on<BlogGetMyBlogs>(_getMyBlogs);
    on<BlogGetBlogsLocally>(_getBlogsLocally);
  }

  void _getBlogsLocally(
    BlogGetBlogsLocally event,
    Emitter<BlogState> emit,
  ) async {
    // Only show loading if we don't have cached data
    if (_cachedBlogs == null || _lastUserId != event.id) {
      emit(BlogLoading());
    }

    final res = await _getBlogsLocallyCase(GetBlogsParams(id: event.id));
    res.fold(
      (l) {
        // Keep cached data on error if available
        if (_cachedBlogs != null) {
          emit(BlogLoaded(blogList: _cachedBlogs));
        } else {
          emit(BlogFailure(message: l.message));
        }
      },
      (r) {
        _cachedBlogs = r;
        _lastUserId = event.id;
        emit(BlogLoaded(blogList: r));
      },
    );
  }

  void _getMyBlogs(BlogGetMyBlogs event, Emitter<BlogState> emit) async {
    // Only show loading if we don't have cached data
    if (_cachedBlogs == null || _lastUserId != event.id) {
      emit(BlogLoading());
    }

    final res = await _getMyBlogsCase(GetBlogsParams(id: event.id));
    res.fold(
      (l) {
        // Keep cached data on error if available
        if (_cachedBlogs != null) {
          emit(BlogLoaded(blogList: _cachedBlogs));
        } else {
          emit(BlogFailure(message: l.message));
        }
      },
      (r) {
        _cachedBlogs = r;
        _lastUserId = event.id;
        emit(BlogLoaded(blogList: r));
      },
    );
  }

  void _loadBlogs(BlogLoadBlogs event, Emitter<BlogState> emit) async {
    // Only show loading if we don't have cached data
    if (_cachedBlogs == null || _lastUserId != event.id) {
      emit(BlogLoading());
    }

    final res = await _getBlogsCase.call(GetBlogsParams(id: event.id));
    res.fold(
      (l) {
        // Keep cached data on error if available
        if (_cachedBlogs != null) {
          emit(BlogLoaded(blogList: _cachedBlogs));
        } else {
          emit(BlogFailure(message: l.message));
        }
      },
      (r) {
        _cachedBlogs = r;
        _lastUserId = event.id;
        emit(BlogLoaded(blogList: r));
      },
    );
  }

  void _postBlog(BlogPostBlog event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _postBlogCase.call(
      PostBlogParams(
        content: event.content,
        title: event.title,
        userId: event.userId,
        image: event.image,
      ),
    );
    res.fold((l) => emit(BlogFailure(message: l.message)), (r) {
      // Optimistically add to cache
      if (_cachedBlogs != null) {
        _cachedBlogs = [r, ..._cachedBlogs!];
      }
      emit(BlogPosted(status: "Blog Posted Successfully"));
    });
  }

  void _deleteBlog(BlogDeleteBlog event, Emitter<BlogState> emit) async {
    // Don't show loading, do optimistic update
    final currentState = state;
    if (currentState is BlogLoaded && currentState.blogList != null) {
      // Optimistically remove from cache
      _cachedBlogs = currentState.blogList!
          .where((blog) => blog.id != event.id)
          .toList();
      emit(BlogLoaded(blogList: _cachedBlogs));
    } else {
      emit(BlogLoading());
    }

    final res = await _deleteBlogCase.call(DeleteBlogParams(id: event.id));
    res.fold(
      (l) {
        // Revert on error
        emit(BlogFailure(message: l.message));
        add(BlogLoadBlogs(id: event.userId));
      },
      (r) {
        emit(BlogDeleted(blog: r));
        // Cache is already updated
      },
    );
  }

  void _updateBlog(BlogUpdateBlog event, Emitter<BlogState> emit) async {
    emit(BlogLoading());
    final res = await _updateBlogCase.call(
      UpdateBlogParams(
        id: event.id,
        title: event.title,
        content: event.content,
        userId: event.userId,
        image: event.image,
      ),
    );
    res.fold((l) => emit(BlogFailure(message: l.message)), (r) {
      // Update cache
      if (_cachedBlogs != null) {
        _cachedBlogs = _cachedBlogs!.map((blog) {
          return blog.id == r.id ? r : blog;
        }).toList();
      }
      emit(BlogUpdated(blog: r));
    });
  }

  // Clear cache when needed
  void clearCache() {
    _cachedBlogs = null;
    _lastUserId = null;
  }
}
