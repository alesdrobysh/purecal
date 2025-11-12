import 'package:flutter/material.dart';
import 'custom_colors.dart';

class AppTheme {
  static const Color _brandGreen = Color(0xFF74B225);

  // Create ColorScheme using hybrid approach:
  // 1. Generate neutral scheme for clean surfaces
  // 2. Generate brand scheme from seed color
  // 3. Merge: brand colors + neutral surfaces
  static ColorScheme _buildLightScheme() {
    final neutralScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    );
    final brandScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.light,
    );

    // Merge: keep brand colors but use neutral surfaces
    return brandScheme.copyWith(
      surface: neutralScheme.surface,
      onSurface: neutralScheme.onSurface,
      surfaceDim: neutralScheme.surfaceDim,
      surfaceBright: neutralScheme.surfaceBright,
      surfaceContainer: neutralScheme.surfaceContainer,
      surfaceContainerLowest: neutralScheme.surfaceContainerLowest,
      surfaceContainerLow: neutralScheme.surfaceContainerLow,
      surfaceContainerHigh: neutralScheme.surfaceContainerHigh,
      surfaceContainerHighest: neutralScheme.surfaceContainerHighest,
      onSurfaceVariant: neutralScheme.onSurfaceVariant,
      inverseSurface: neutralScheme.inverseSurface,
      onInverseSurface: neutralScheme.onInverseSurface,
      shadow: neutralScheme.shadow,
      scrim: neutralScheme.scrim,
      surfaceTint: neutralScheme.surfaceTint,
    );
  }

  static ColorScheme _buildDarkScheme() {
    final neutralScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    );
    final brandScheme = ColorScheme.fromSeed(
      seedColor: _brandGreen,
      brightness: Brightness.dark,
    );

    return brandScheme.copyWith(
      surface: neutralScheme.surface,
      onSurface: neutralScheme.onSurface,
      surfaceDim: neutralScheme.surfaceDim,
      surfaceBright: neutralScheme.surfaceBright,
      surfaceContainer: neutralScheme.surfaceContainer,
      surfaceContainerLowest: neutralScheme.surfaceContainerLowest,
      surfaceContainerLow: neutralScheme.surfaceContainerLow,
      surfaceContainerHigh: neutralScheme.surfaceContainerHigh,
      surfaceContainerHighest: neutralScheme.surfaceContainerHighest,
      onSurfaceVariant: neutralScheme.onSurfaceVariant,
      inverseSurface: neutralScheme.inverseSurface,
      onInverseSurface: neutralScheme.onInverseSurface,
      shadow: neutralScheme.shadow,
      scrim: neutralScheme.scrim,
      surfaceTint: neutralScheme.surfaceTint,
    );
  }

  static final ColorScheme _lightScheme = _buildLightScheme();
  static final ColorScheme _darkScheme = _buildDarkScheme();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _lightScheme,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors.light,
    ],
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _darkScheme,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: 4,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      CustomColors.dark,
    ],
  );
}
