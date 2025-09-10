import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/common/params/get_blogs_params.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';

class GetMyBlogs implements Usecase<List<Blog>, GetBlogsParams> {
  final BlogRepository blogRepository;

  GetMyBlogs({required this.blogRepository});
  @override
  Future<Either<Failure, List<Blog>>> call(GetBlogsParams params) {
    return blogRepository.getMyBlogs(params.id);
  }
}
