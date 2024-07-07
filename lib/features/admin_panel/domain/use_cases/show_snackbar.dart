import 'package:flutter/material.dart';

showSnackBar(String message, BuildContext context, Color color) {
  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Container(
        margin: const EdgeInsets.all(20.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Colors.white),
        ),
      ),
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(5.0),
      backgroundColor: color,
    ),
  );
}
