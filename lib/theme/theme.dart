import 'package:flutter/material.dart';

class FlutterZoneTwoTheme {
  static ThemeData get light {
    return ThemeData(
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 160, 234, 149)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFA0EA95),
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
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
