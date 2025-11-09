import 'package:flutter/material.dart';

/// Global decoration system for consistent themed shapes across the app.
/// Provides theme-aware BoxDecoration styles that adapt to light/dark mode.
class AppShapes {
  /// Primary container with background fill and border (8px radius).
  static BoxDecoration greenContainer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 2,
      ),
    );
  }

  /// Subtle container with background fill only, no border (8px radius).
  static BoxDecoration greenContainerSubtle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(8),
    );
  }

  /// Outlined container with transparent background and border only (8px radius).
  static BoxDecoration greenContainerOutlined(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 2,
      ),
    );
  }

  /// Large container variant with 12px border radius.
  static BoxDecoration greenContainerLarge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: colorScheme.outlineVariant,
        width: 2,
      ),
    );
  }

  /// Small rounded badge for labels and status indicators (12px radius).
  static BoxDecoration greenBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Informational container for tips, summaries, and help text (12px radius).
  static BoxDecoration greenInfoBox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Button decoration with solid background (8px radius).
  static BoxDecoration greenButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(8),
    );
  }
}
