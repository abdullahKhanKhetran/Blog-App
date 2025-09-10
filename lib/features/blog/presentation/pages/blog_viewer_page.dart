import 'dart:io';

import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/common/utils/File_from_url.dart';
import 'package:blog_app/core/common/utils/pick_image.dart';
import 'package:blog_app/core/common/utils/blob_to_file.dart';
import 'package:blog_app/core/common/utils/show_dialog.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class BlogViewerPage extends StatefulWidget {
  final Blog blog;
  const BlogViewerPage({super.key, required this.blog});
  static route(Blog blog) =>
      MaterialPageRoute(builder: (context) => BlogViewerPage(blog: blog));
  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;
  late final TextEditingController _titleController;
  bool _isEditing = false;
  File? currentImage;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    final hasImage = widget.blog.imageUrl.isNotEmpty;
    _contentController = TextEditingController(text: widget.blog.content);
    _titleController = TextEditingController(text: widget.blog.title);
    // After first frame, determine connectivity and prepare image if offline
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final offlineImageBytes = widget.blog.image;
      isOnline =
          (context.read<AppConnectionCubit>().state is AppConnectionSuccesful);
      if (!isOnline && offlineImageBytes != null) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/${widget.blog.id}.jpg';
        currentImage = await blobToFile(offlineImageBytes, filePath);
        if (mounted) setState(() {});
      }
      if (isOnline && hasImage) {
        setState(() async {
          currentImage = await networkImageToFile(
            widget.blog.imageUrl,
            "${widget.blog.id}.jpeg",
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _delete() {
    // TODO: Implement delete logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure about this?\nThis Blog will be deleted!',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              context.read<BlogBloc>().add(
                BlogDeleteBlog(id: widget.blog.id, userId: widget.blog.userId),
              );
              Navigator.of(context).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onFabPressed() {
    if (_isEditing) {
      // Save path
      if (_formKey.currentState?.validate() ?? false) {
        print("Updating..");
        if (!isOnline) {
          showSnackbar(
            context,
            'You need to be online to edit blogs',
            'Offline',
          );
          return;
        }
        _save();
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _save() {
    context.read<BlogBloc>().add(
      BlogUpdateBlog(
        id: widget.blog.id,
        title: _titleController.text,
        content: _contentController.text,
        userId: (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id,
        image: currentImage!,
      ),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    final hasImage = blog.imageUrl.isNotEmpty;
    isOnline =
        (context.read<AppConnectionCubit>().state is AppConnectionSuccesful);

    return BlocConsumer<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogFailure) {
          showSnackbar(context, state.message);
        } else if (state is BlogDeleted) {
          showSnackbar(
            context,
            "Blog ${state.blog.title} deleted Successfully",
            "Deleted",
          );
          Navigator.of(
            context,
          ).pushAndRemoveUntil(BlogPage.route(), (route) => false);
        } else if (state is BlogUpdated) {
          showSnackbar(context, "Blog has been updated ", "Success");
        }
      },
      builder: (context, state) {
        if (state is BlogLoading) {
          return const Loader();
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                _isEditing ? 'Edit mode' : 'View mode',
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                IconButton(
                  onPressed: _delete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                ),
              ],
            ),
            extendBodyBehindAppBar: true,
            floatingActionButton: FloatingActionButton(
              onPressed: _onFabPressed,
              child: Icon(_isEditing ? Icons.save : Icons.edit),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top meta (author and date) with border restored
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppPallete.borderColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Author: ${blog.name ?? "Unknown"}',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Posted on ${_formatDate(blog.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Image header with loading/error placeholders
                      GestureDetector(
                        onTap: !_isEditing
                            ? null
                            : () async {
                                final picked = await pickImage();
                                if (picked != null) {
                                  setState(() => currentImage = picked);
                                }
                              },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 220,
                            width: double.infinity,
                            child: currentImage != null
                                ? Image.file(
                                    currentImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : (isOnline && hasImage)
                                ? Image.network(
                                    blog.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 48,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.black12,
                                    child: const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Title label and field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'Title',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      TextFormField(
                        controller: _titleController,
                        readOnly: !_isEditing,
                        maxLines: 1,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Title cannot be empty';
                          if (v.length < 3)
                            return 'Title must be at least 3 characters';
                          return null;
                        },
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      ),

                      const SizedBox(height: 12),

                      // Content label and field
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          'Content',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      TextFormField(
                        controller: _contentController,
                        readOnly: !_isEditing,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Content',
                          prefixIcon: Icon(Icons.notes_outlined),
                        ),
                        validator: (value) {
                          final v = value?.trim() ?? '';
                          if (v.isEmpty) return 'Content cannot be empty';
                          if (v.length < 10)
                            return 'Content must be at least 10 characters';
                          return null;
                        },
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
