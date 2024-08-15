import 'package:flutter/material.dart';

class FlutterZoneTwoTheme {
  static ThemeData get light {
    return ThemeData(
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 160, 234, 149)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFA0EA95),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.black, fontSize: 48, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 8, 20, 5),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFFA0EA95),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(
            color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
