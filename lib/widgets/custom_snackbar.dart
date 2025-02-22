import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  info,
}

void showCustomSnackBar(
    BuildContext context, String message) {
  Color textColor = Colors.white;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: textColor,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
