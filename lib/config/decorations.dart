import 'package:flutter/material.dart';

/// Centralized color palette for the app.
/// Exposes theme-aware color getters based on the Material 3 ColorScheme.
class AppColors {
  // Theme-aware color getters
  static Color containerBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainer;
  }

  static Color containerBorder(BuildContext context) {
    return Theme.of(context).colorScheme.outlineVariant;
  }

  static Color badgeBackground(BuildContext context) {
    return Theme.of(context).colorScheme.secondaryContainer;
  }

  static Color badgeText(BuildContext context) {
    return Theme.of(context).colorScheme.onSecondaryContainer;
  }

  static Color iconAccent(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color buttonBackground(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color infoBoxBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
  }

  static Color infoBoxText(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  static Color infoBoxIcon(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color inputBackground(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerHighest;
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
