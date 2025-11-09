/// Represents extracted nutrition data with confidence scores
class NutritionExtraction {
  // Extracted values (per 100g)
  final double? calories;
  final double? protein;
  final double? fat;
  final double? carbs;

  // Confidence scores (0.0 - 1.0)
  final double caloriesConfidence;
  final double proteinConfidence;
  final double fatConfidence;
  final double carbsConfidence;

  // Raw text that was parsed
  final String sourceText;

  // Detected language
  final String? language;

  // Detected serving size (if any)
  final double? servingSize;

  NutritionExtraction({
    this.calories,
    this.protein,
    this.fat,
    this.carbs,
    this.caloriesConfidence = 0.0,
    this.proteinConfidence = 0.0,
    this.fatConfidence = 0.0,
    this.carbsConfidence = 0.0,
    required this.sourceText,
    this.language,
    this.servingSize,
  });

  /// Overall confidence score (average of all fields)
  double get overallConfidence {
    final scores = [
      caloriesConfidence,
      proteinConfidence,
      fatConfidence,
      carbsConfidence,
    ];
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Check if extraction is reliable (>= 70% confidence)
  bool get isReliable => overallConfidence >= 0.7;

  /// Get confidence level category
  ConfidenceLevel get confidenceLevel {
    if (overallConfidence >= 0.9) return ConfidenceLevel.high;
    if (overallConfidence >= 0.7) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  /// Check if all required fields were extracted
  bool get isComplete {
    return calories != null && protein != null && fat != null && carbs != null;
  }

  /// Get list of missing fields
  List<String> get missingFields {
    final missing = <String>[];
    if (calories == null) missing.add('calories');
    if (protein == null) missing.add('protein');
    if (fat == null) missing.add('fat');
    if (carbs == null) missing.add('carbs');
    return missing;
  }

  @override
  String toString() {
    return '''
NutritionExtraction(
  calories: $calories (${(caloriesConfidence * 100).toStringAsFixed(0)}%)
  protein: $protein g (${(proteinConfidence * 100).toStringAsFixed(0)}%)
  fat: $fat g (${(fatConfidence * 100).toStringAsFixed(0)}%)
  carbs: $carbs g (${(carbsConfidence * 100).toStringAsFixed(0)}%)
  overall: ${(overallConfidence * 100).toStringAsFixed(0)}%
  complete: $isComplete
)''';
  }

  /// Convert to map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'caloriesConfidence': caloriesConfidence,
      'proteinConfidence': proteinConfidence,
      'fatConfidence': fatConfidence,
      'carbsConfidence': carbsConfidence,
      'sourceText': sourceText,
      'language': language,
      'servingSize': servingSize,
      'overallConfidence': overallConfidence,
      'isComplete': isComplete,
    };
  }

  /// Create from map
  factory NutritionExtraction.fromMap(Map<String, dynamic> map) {
    return NutritionExtraction(
      calories: map['calories']?.toDouble(),
      protein: map['protein']?.toDouble(),
      fat: map['fat']?.toDouble(),
      carbs: map['carbs']?.toDouble(),
      caloriesConfidence: map['caloriesConfidence']?.toDouble() ?? 0.0,
      proteinConfidence: map['proteinConfidence']?.toDouble() ?? 0.0,
      fatConfidence: map['fatConfidence']?.toDouble() ?? 0.0,
      carbsConfidence: map['carbsConfidence']?.toDouble() ?? 0.0,
      sourceText: map['sourceText'] ?? '',
      language: map['language'],
      servingSize: map['servingSize']?.toDouble(),
    );
  }
}

/// Confidence level categories
enum ConfidenceLevel {
  high, // >= 90%
  medium, // >= 70%
  low, // < 70%
}

/// Extension to get display properties for confidence levels
extension ConfidenceLevelDisplay on ConfidenceLevel {
  String get emoji {
    switch (this) {
      case ConfidenceLevel.high:
        return '✅';
      case ConfidenceLevel.medium:
        return '⚠️';
      case ConfidenceLevel.low:
        return '❌';
    }
  }

  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High confidence';
      case ConfidenceLevel.medium:
        return 'Medium confidence';
      case ConfidenceLevel.low:
        return 'Low confidence - please verify';
    }
  }
}
