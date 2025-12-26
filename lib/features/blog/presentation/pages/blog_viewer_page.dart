import 'dart:io';

import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_app/core/common/entities/blog.dart';
import 'package:blog_app/core/common/utils/file_from_url.dart';
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
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.blog.content);
    _titleController = TextEditingController(text: widget.blog.title);
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoadingImage = true);

    try {
      final isOnline =
          context.read<AppConnectionCubit>().state is AppConnectionSuccesful;
      final hasImage = widget.blog.imageUrl.isNotEmpty;

      if (!isOnline && widget.blog.image != null) {
        // Offline mode - use blob
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/${widget.blog.id}.jpg';
        currentImage = await blobToFile(widget.blog.image!, filePath);
      } else if (isOnline && hasImage) {
        // Online mode - download from URL
        currentImage = await networkImageToFile(
          widget.blog.imageUrl,
          "${widget.blog.id}.jpeg",
        );
      }
    } catch (e) {
      print('[BlogViewer] Error loading image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Blog'),
        content: Text(
          'Are you sure you want to delete "${widget.blog.title}"? This action cannot be undone.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel", style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              context.read<BlogBloc>().add(
                BlogDeleteBlog(id: widget.blog.id, userId: widget.blog.userId),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _onFabPressed() {
    if (_isEditing) {
      if (_formKey.currentState?.validate() ?? false) {
        final isOnline =
            context.read<AppConnectionCubit>().state is AppConnectionSuccesful;

        if (!isOnline) {
          showSnackbar(
            context,
            'You need to be online to edit blogs',
            'Offline',
          );
          return;
        }

        if (currentImage == null) {
          showSnackbar(context, 'Please select an image');
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
    return BlocConsumer<BlogBloc, BlogState>(
      listener: (context, state) {
        if (state is BlogFailure) {
          showSnackbar(context, state.message);
        } else if (state is BlogDeleted) {
          Navigator.of(
            context,
          ).pushAndRemoveUntil(BlogPage.route(), (route) => false);
          showSnackbar(context, "Blog deleted successfully", "Success");
        } else if (state is BlogUpdated) {
          showSnackbar(context, "Blog updated successfully", "Success");
        }
      },
      builder: (context, state) {
        if (state is BlogLoading) {
          return const Scaffold(body: Loader());
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(_isEditing ? 'Edit Blog' : 'View Blog'),
            actions: [
              IconButton(
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
              ),
            ],
          ),
          extendBodyBehindAppBar: false,
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
                    // Metadata card
                    Container(
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
                              'Author: ${widget.blog.name ?? "Unknown"}',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatDate(widget.blog.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Image section
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
                          child: _isLoadingImage
                              ? Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : currentImage != null
                              ? Image.file(
                                  currentImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) {
                                    return _buildImagePlaceholder(
                                      Icons.broken_image_outlined,
                                    );
                                  },
                                )
                              : _buildImagePlaceholder(
                                  Icons.image_not_supported_outlined,
                                ),
                        ),
                      ),
                    ),

                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Tap image to change',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppPallete.gradient2,
                                fontSize: 12,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Title section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Title',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _titleController,
                      readOnly: !_isEditing,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        enabled: _isEditing,
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Title cannot be empty';
                        if (v.length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    ),

                    const SizedBox(height: 12),

                    // Content section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'Content',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _contentController,
                      readOnly: !_isEditing,
                      maxLines: null,
                      minLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Content',
                        prefixIcon: const Icon(Icons.notes_outlined),
                        enabled: _isEditing,
                      ),
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) return 'Content cannot be empty';
                        if (v.length < 10) {
                          return 'Content must be at least 10 characters';
                        }
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
      },
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      color: Colors.black12,
      child: Center(child: Icon(icon, size: 48, color: Colors.grey)),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
