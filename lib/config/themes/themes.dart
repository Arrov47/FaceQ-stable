import 'package:flutter/material.dart';
final light = ThemeData(
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.grey.shade400
  ),
inputDecorationTheme: InputDecorationTheme(
  hintStyle: TextStyle(fontStyle: FontStyle.italic),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue)
  ),

),
  listTileTheme: ListTileThemeData(
    iconColor: Colors.black
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4)
      )),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.blue)
    )
  ),
  textTheme: TextTheme(
  )
);
final dark = ThemeData(

);