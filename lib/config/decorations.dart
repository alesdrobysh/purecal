import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// Exposes the primary green MaterialColor and provides theme-aware color getters.
class AppColors {
  /// Primary green MaterialColor with all shades (50, 100, 200, ..., 900)
  /// Access shades via: AppColors.green.shade50, AppColors.green.shade100, etc.
  static const MaterialColor green = Colors.green;

  // Theme-aware color getters
  static Color containerBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? green.shade900
        : green.shade50;
  }

  static Color containerBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? green.shade600
        : green.shade300;
  }

  static Color badgeBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? green.shade800
        : green.shade100;
  }

  static Color badgeText(BuildContext context) {
    return green.shade700;
  }

  static Color iconAccent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? green.shade300
        : green.shade700;
  }

  static Color buttonBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? green.shade700
        : green.shade500;
  }

  static Color infoBoxBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? colorScheme.surfaceContainerHighest : colorScheme.surfaceContainer;
  }

  static Color infoBoxText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color infoBoxIcon(BuildContext context) {
    return green.shade700;
  }

  static Color inputBackground(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? colorScheme.surfaceContainerHighest : green.shade50;
  }
}

/// Global decoration system for consistent green-themed shapes across the app.
/// Provides theme-aware BoxDecoration styles that adapt to light/dark mode.
class AppShapes {
  /// Primary green container with background fill and border (8px radius).
  static BoxDecoration greenContainer(BuildContext context) {
    return BoxDecoration(
      color: AppColors.containerBackground(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.containerBorder(context),
        width: 2,
      ),
    );
  }

  /// Subtle green container with background fill only, no border (8px radius).
  static BoxDecoration greenContainerSubtle(BuildContext context) {
    return BoxDecoration(
      color: AppColors.containerBackground(context),
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Outlined green container with transparent background and border only (8px radius).
  static BoxDecoration greenContainerOutlined(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: AppColors.containerBorder(context),
        width: 2,
      ),
    );
  }

  /// Large green container variant with 12px border radius.
  static BoxDecoration greenContainerLarge(BuildContext context) {
    return BoxDecoration(
      color: AppColors.containerBackground(context),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.containerBorder(context),
        width: 2,
      ),
    );
  }

  /// Small rounded badge for labels and status indicators (12px radius).
  static BoxDecoration greenBadge(BuildContext context) {
    return BoxDecoration(
      color: AppColors.badgeBackground(context),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Informational container for tips, summaries, and help text (12px radius).
  static BoxDecoration greenInfoBox(BuildContext context) {
    return BoxDecoration(
      color: AppColors.infoBoxBackground(context),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Button decoration with solid green background (8px radius).
  static BoxDecoration greenButton(BuildContext context) {
    return BoxDecoration(
      color: AppColors.buttonBackground(context),
      borderRadius: BorderRadius.circular(8),
    );
  }
}
