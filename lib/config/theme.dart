import 'package:flutter/material.dart';
import 'custom_colors.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF74B225);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors.light,
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors.dark,
    ],
  );
}
