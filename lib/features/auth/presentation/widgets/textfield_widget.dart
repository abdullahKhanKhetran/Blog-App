import 'package:blog_app/core/color_pallate.dart';
import 'package:flutter/material.dart';

class TextfieldWidget extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;

  const TextfieldWidget({
    super.key,
    this.hintText = "Enter text",
    this.controller,
    this.isPassword = false,
  });

  @override
  State<TextfieldWidget> createState() => _TextfieldWidgetState();
}

class _TextfieldWidgetState extends State<TextfieldWidget> {
  bool obscureText = true;

  @override
  void initState() {
    super.initState();
    // If it’s not a password, no need to obscure
    obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ${widget.hintText}';
        }
        return null;
      },
      style: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppPallete.whiteColor),
      controller: widget.controller,
      obscureText: widget.isPassword ? obscureText : false,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(18.0),
        hintText: widget.hintText,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscureText = !obscureText;
                  });
                },
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
