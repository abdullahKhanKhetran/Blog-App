import 'package:flutter/material.dart';

showSnackbar(BuildContext context, String message, [String title = "Error"]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message, style: Theme.of(context).textTheme.bodySmall),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
