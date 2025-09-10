import 'package:blog_app/core/common/params/post_blog_params.dart';
import 'package:blog_app/core/error/faliure.dart';
import 'package:blog_app/core/usecase_interfaces/usecase_interface.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:blog_app/features/blog/domain/repositories/blog_respository.dart';
import 'package:fpdart/fpdart.dart';

class PostBlog implements Usecase<BlogModel, PostBlogParams> {
  final BlogRepository blogRepository;
  const PostBlog({required this.blogRepository});
  @override
  Future<Either<Failure, BlogModel>> call(PostBlogParams params) async {
    return await blogRepository.postBlog(
      title: params.title,
      content: params.content,
      userId: params.userId,
      image: params.image,
    );
  }
}
