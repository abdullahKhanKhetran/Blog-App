import 'package:flutter/material.dart';

class BlogContentField extends StatefulWidget {
  final TextEditingController controller;
  const BlogContentField({required this.controller, super.key});

  @override
  State<BlogContentField> createState() => _BlogContentFieldState();
}

class _BlogContentFieldState extends State<BlogContentField> {
  TextEditingController? _contentController;
  @override
  void initState() {
    super.initState();
    _contentController = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: 'Content',
        hintStyle: Theme.of(context).textTheme.labelSmall,
        prefixIcon: const Icon(Icons.notes_outlined),
      ),
      controller: _contentController,
      maxLines: null,
      style: Theme.of(context).textTheme.bodySmall,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Content cannot be empty';
        if (v.length < 10) return 'Content must be at least 10 characters';
        return null;
      },
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}
