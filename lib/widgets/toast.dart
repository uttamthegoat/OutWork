import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

void showCustomToast(String message, String type) {
  Color toastColor;

  // Determine the color based on the type
  switch (type) {
    case 'success':
      toastColor = Colors.green;
      break;
    case 'error':
      toastColor = Colors.red;
      break;
    default:
      toastColor = Colors.black; // Default color
  }

  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 2,
    backgroundColor: toastColor,
    textColor: Colors.white,
    fontSize: 13.0,
  );
}
