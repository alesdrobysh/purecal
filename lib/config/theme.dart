import 'package:flutter/material.dart';
import 'decorations.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: AppColors.green,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: AppColors.green,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      foregroundColor: Colors.white,
    ),
  );
}
