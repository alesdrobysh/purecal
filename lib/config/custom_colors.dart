import 'package:flutter/material.dart';

/// Custom color extension for nutrition data visualization and semantic actions.
/// Provides light/dark mode aware colors with proper contrast ratios for accessibility.
@immutable
class CustomColors extends ThemeExtension<CustomColors> {
  // Nutrition data visualization colors
  final Color caloriesColor;
  final Color proteinColor;
  final Color fatColor;
  final Color carbsColor;

  // Semantic action/icon colors
  final Color infoColor;
  final Color themeColor;
  final Color exportColor;
  final Color dangerColor;
  final Color warningColor;

  const CustomColors({
    required this.caloriesColor,
    required this.proteinColor,
    required this.fatColor,
    required this.carbsColor,
    required this.infoColor,
    required this.themeColor,
    required this.exportColor,
    required this.dangerColor,
    required this.warningColor,
  });

  /// Light mode color palette
  static const CustomColors light = CustomColors(
    // Nutrition colors - vibrant for light mode
    caloriesColor: Color(0xFFFF6F00), // Deep orange
    proteinColor: Color(0xFFD32F2F), // Red
    fatColor: Color(0xFFFBC02D), // Yellow
    carbsColor: Color(0xFF1976D2), // Blue

    // Semantic colors - standard for light mode
    infoColor: Color(0xFF1976D2), // Blue
    themeColor: Color(0xFF7B1FA2), // Purple
    exportColor: Color(0xFF388E3C), // Green
    dangerColor: Color(0xFFD32F2F), // Red
    warningColor: Color(0xFFFF6F00), // Orange
  );

  /// Dark mode color palette
  static const CustomColors dark = CustomColors(
    // Nutrition colors - lighter, more saturated for dark mode visibility
    caloriesColor: Color(0xFFFFB74D), // Light orange
    proteinColor: Color(0xFFE57373), // Light red
    fatColor: Color(0xFFFFD54F), // Light yellow
    carbsColor: Color(0xFF64B5F6), // Light blue

    // Semantic colors - lighter variants for dark mode
    infoColor: Color(0xFF64B5F6), // Light blue
    themeColor: Color(0xFFBA68C8), // Light purple
    exportColor: Color(0xFF81C784), // Light green
    dangerColor: Color(0xFFE57373), // Light red
    warningColor: Color(0xFFFFB74D), // Light orange
  );

  @override
  CustomColors copyWith({
    Color? caloriesColor,
    Color? proteinColor,
    Color? fatColor,
    Color? carbsColor,
    Color? infoColor,
    Color? themeColor,
    Color? exportColor,
    Color? dangerColor,
    Color? warningColor,
  }) {
    return CustomColors(
      caloriesColor: caloriesColor ?? this.caloriesColor,
      proteinColor: proteinColor ?? this.proteinColor,
      fatColor: fatColor ?? this.fatColor,
      carbsColor: carbsColor ?? this.carbsColor,
      infoColor: infoColor ?? this.infoColor,
      themeColor: themeColor ?? this.themeColor,
      exportColor: exportColor ?? this.exportColor,
      dangerColor: dangerColor ?? this.dangerColor,
      warningColor: warningColor ?? this.warningColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      caloriesColor: Color.lerp(caloriesColor, other.caloriesColor, t)!,
      proteinColor: Color.lerp(proteinColor, other.proteinColor, t)!,
      fatColor: Color.lerp(fatColor, other.fatColor, t)!,
      carbsColor: Color.lerp(carbsColor, other.carbsColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      themeColor: Color.lerp(themeColor, other.themeColor, t)!,
      exportColor: Color.lerp(exportColor, other.exportColor, t)!,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
    );
  }
}

/// Extension method to easily access CustomColors from BuildContext
extension CustomColorsExtension on BuildContext {
  CustomColors get customColors =>
      Theme.of(this).extension<CustomColors>() ?? CustomColors.light;
}
