import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteBlogParams {
  final String id;
  const DeleteBlogParams({required this.id});
}

class DeleteBlog implements Usecase<Blog, DeleteBlogParams> {
  final BlogRepository blogRepository;
  const DeleteBlog({required this.blogRepository});
  @override
  Future<Either<Failure, Blog>> call(DeleteBlogParams params) {
    return blogRepository.deleteBlog(id: params.id);
  }
}
