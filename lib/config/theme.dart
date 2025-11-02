
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.green,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
    ),
  );
}
