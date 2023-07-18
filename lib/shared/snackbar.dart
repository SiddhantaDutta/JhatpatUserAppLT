import 'package:flutter/material.dart';

void showSnackBar(
    {required BuildContext context,
    required String content,
    Color bgColor = Colors.red,
    int millisecond = 1500}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: millisecond),
        backgroundColor: bgColor,
        content: Text(content),
      ),
    );
}
