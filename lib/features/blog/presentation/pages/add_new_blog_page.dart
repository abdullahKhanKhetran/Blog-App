import 'dart:io';

import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/utils/pick_image.dart';
import 'package:blog_app/core/common/utils/show_dialog.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_content_field.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_title_field.dart';
import 'package:flutter/material.dart';
import 'package:blog_app/core/color_pallate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogPage extends StatefulWidget {
  const AddNewBlogPage({super.key});
  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isLoading = false;
  File? image;

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _addBlog() {
    // TODO: Implement add blog functionality
    if (_formKey.currentState!.validate()) {
      if (image == null) {
        showSnackbar(context, "Please choose an Image");
        return;
      }
      print('Title: ${_titleController.text}');
      print('Content: ${_contentController.text}');
      final userState = context.read<AppUserCubit>().state;
      if (userState is AppUserLoggedIn) {
        context.read<BlogBloc>().add(
          BlogPostBlog(
            title: _titleController.text,
            content: _contentController.text,
            userId: userState.user.id,
            image: image!,
          ),
        );
      }
      // Add your blog creation logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is BlogFailure) {
          setState(() {
            _isLoading = false;
          });
          showSnackbar(context, state.message);
        } else if (state is BlogPosted) {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(
            context,
          ).pushAndRemoveUntil(BlogPage.route(), (route) => false);
          showSnackbar(context, state.status, "Success");
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: selectImage,
                  child:
                      // (image != null)
                      //     ? Container(
                      //         margin: EdgeInsets.all(5),
                      //         decoration: BoxDecoration(
                      //           shape: BoxShape.rectangle,
                      //           borderRadius: BorderRadius.circular(10),
                      //           image: DecorationImage(
                      //             image: Image.file(image!).image,
                      //             fit: BoxFit.cover,
                      //           ),
                      //         ),
                      //         height: 200,
                      //         width: double.infinity,
                      //       )
                      //     :
                      Container(
                        height: 200,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          shape: BoxShape.rectangle,
                          image: (image != null)
                              ? DecorationImage(
                                  image: Image.file(image!).image,
                                  fit: BoxFit.cover,
                                )
                              : null,
                          border: BoxBorder.all(color: AppPallete.borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Icon(Icons.folder), Text("Choose Image")],
                        ),
                      ),
                ),
                const SizedBox(height: 30),

                // Title Field
                BlogTitleField(controller: _titleController),

                const SizedBox(height: 20),

                // Content Field
                BlogContentField(controller: _contentController),

                const SizedBox(height: 30),

                // Submit Button
                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppPallete.gradient1,
                        AppPallete.gradient2,
                        // Color.fromARGB(255, 218, 29, 192),
                        // Color.fromARGB(179, 19, 89, 238),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addBlog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppPallete.whiteColor,
                              ),
                            ),
                          )
                        : const Text(
                            'Publish Blog',
                            style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
