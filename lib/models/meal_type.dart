import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks;

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MealType.breakfast:
        return l10n.breakfast;
      case MealType.lunch:
        return l10n.lunch;
      case MealType.dinner:
        return l10n.dinner;
      case MealType.snacks:
        return l10n.snacks;
    }
  }

  String get emoji {
    switch (this) {
      case MealType.breakfast:
        return '🍳';
      case MealType.lunch:
        return '🍽️';
      case MealType.dinner:
        return '🍲';
      case MealType.snacks:
        return '🍿';
    }
  }

  String displayNameWithEmoji(BuildContext context) =>
      '$emoji ${displayName(context)}';

  /// Get the meal type based on the time of day
  static MealType fromTime(DateTime time) {
    final hour = time.hour;

    if (hour >= 6 && hour < 11) {
      return MealType.breakfast;
    } else if (hour >= 11 && hour < 15) {
      return MealType.lunch;
    } else if (hour >= 15 && hour < 20) {
      return MealType.dinner;
    } else {
      return MealType.snacks;
    }
  }

  /// Get meal type from string (for database)
  static MealType? fromString(String? value) {
    if (value == null) return null;
    try {
      return MealType.values.firstWhere(
        (e) => e.name == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Convert to string for database storage
  String toDatabase() => name;
}
