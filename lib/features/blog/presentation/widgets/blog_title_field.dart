import 'package:flutter/material.dart';

class BlogTitleField extends StatefulWidget {
  final TextEditingController controller;
  const BlogTitleField({required this.controller, super.key});

  @override
  State<BlogTitleField> createState() => _BlogTitleFieldState();
}

class _BlogTitleFieldState extends State<BlogTitleField> {
  TextEditingController? _contentController;
  @override
  void initState() {
    super.initState();
    _contentController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _contentController,
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: Theme.of(context).textTheme.labelSmall,
        prefixIcon: const Icon(Icons.title),
      ),
      maxLines: 1,
      style: Theme.of(context).textTheme.bodyMedium,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Title cannot be empty';
        if (v.length < 3) return 'Title must be at least 3 characters';
        return null;
      },
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
