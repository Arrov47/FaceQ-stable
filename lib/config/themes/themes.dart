import 'package:flutter/material.dart';
final light = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    color: Colors.transparent
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.blue,
    selectionHandleColor: Colors.blue,
    selectionColor: Colors.grey.shade400
  ),
iconTheme: IconThemeData(
  color: Colors.black
),

inputDecorationTheme: const InputDecorationTheme(
    suffixIconColor: Colors.black,
  labelStyle: TextStyle(color: Colors.black),
  hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.black),
    errorStyle: TextStyle(color: Colors.black),
    helperStyle: TextStyle(color: Colors.black),
    floatingLabelStyle: TextStyle(color: Colors.black),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.blue)
  ),

  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black))

),
  listTileTheme: const ListTileThemeData(
    iconColor: Colors.black
  ),

    cardTheme: const CardTheme(
        color: Colors.black,
        shadowColor: Colors.white,
        shape: Border.fromBorderSide(BorderSide(color: Colors.white))
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
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color:Colors.black,overflow: TextOverflow.ellipsis,),
    labelMedium: TextStyle(color:Colors.black,overflow: TextOverflow.ellipsis,),
    titleMedium: TextStyle(color:Colors.black,),
  )
);
final dark = ThemeData(
scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent
    ),
    textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.blue,
        selectionHandleColor: Colors.blue,
        selectionColor: Colors.white60
    ),
    cardTheme: const CardTheme(
      color: Colors.black,
      shadowColor: Colors.white,
      shape: Border.fromBorderSide(BorderSide(color: Colors.white))
    ),
    iconTheme: const IconThemeData(
        color: Colors.white,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      suffixIconColor: Colors.white,
        labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.white),
errorStyle: TextStyle(color: Colors.white),
floatingLabelStyle: TextStyle(color: Colors.white),
        helperStyle: TextStyle(color: Colors.white),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue)
      ),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white))

    ),
    listTileTheme: const ListTileThemeData(
        iconColor: Colors.white
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
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(color: Colors.white),
      labelLarge: TextStyle(color:Colors.white,overflow: TextOverflow.ellipsis,),
      labelMedium: TextStyle(color:Colors.white,overflow: TextOverflow.ellipsis,),
      titleMedium: TextStyle(color:Colors.white,),
    )
);