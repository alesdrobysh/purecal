enum MealType {
  breakfast,
  lunch,
  dinner,
  snacks;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snacks:
        return 'Snacks';
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

  String get displayNameWithEmoji => '$emoji $displayName';

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
