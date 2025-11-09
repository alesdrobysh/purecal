import '../../models/nutrition_extraction.dart';

/// Service for parsing nutrition information from OCR text
/// Supports multiple languages: English, Spanish, Russian, Polish, Belarusian
class NutritionTextParser {
  /// Parse nutrition data from OCR text
  ///
  /// Uses pattern matching and heuristics to extract:
  /// - Calories/Energy (kcal or kJ)
  /// - Protein (g)
  /// - Fat (g)
  /// - Carbohydrates (g)
  ///
  /// Returns [NutritionExtraction] with values and confidence scores
  static NutritionExtraction parse(String text) {
    // Normalize text: remove extra whitespace, standardize separators
    final normalizedText = _normalizeText(text);

    // Detect language
    final language = _detectLanguage(normalizedText);

    // Extract nutrition values
    final calories = _extractCalories(normalizedText);
    final protein = _extractProtein(normalizedText);
    final fat = _extractFat(normalizedText);
    final carbs = _extractCarbs(normalizedText);
    final servingSize = _extractServingSize(normalizedText);

    return NutritionExtraction(
      calories: calories?.value,
      protein: protein?.value,
      fat: fat?.value,
      carbs: carbs?.value,
      caloriesConfidence: calories?.confidence ?? 0.0,
      proteinConfidence: protein?.confidence ?? 0.0,
      fatConfidence: fat?.confidence ?? 0.0,
      carbsConfidence: carbs?.confidence ?? 0.0,
      sourceText: text,
      language: language,
      servingSize: servingSize,
    );
  }

  /// Normalize text for better pattern matching
  static String _normalizeText(String text) {
    return text
        // Convert to lowercase for case-insensitive matching
        .toLowerCase()
        // Replace multiple whitespace with single space
        .replaceAll(RegExp(r'\s+'), ' ')
        // Standardize decimal separators (some countries use comma)
        .replaceAll(',', '.')
        // Remove common OCR artifacts
        .replaceAll(RegExp(r'[|¦]'), 'i')
        // Normalize dashes and slashes
        .replaceAll(RegExp(r'[—–−]'), '-')
        .replaceAll(RegExp(r'[⁄∕]'), '/')
        .trim();
  }

  /// Detect language from nutrition label keywords
  static String _detectLanguage(String text) {
    // Language detection based on common nutrition keywords
    if (RegExp(r'\b(calorías|energía|grasas|proteínas|glúcidos|hidratos)\b').hasMatch(text)) {
      return 'es'; // Spanish
    }
    if (RegExp(r'\b(калории|калорый|энергия|жиры|белки|углеводы)\b').hasMatch(text)) {
      return 'ru'; // Russian
    }
    if (RegExp(r'\b(kalorie|energia|tłuszcze|białko|węglowodany)\b').hasMatch(text)) {
      return 'pl'; // Polish
    }
    if (RegExp(r'\b(каларыйнасць|энергія|тлушчы|бялкі|вугляводы)\b').hasMatch(text)) {
      return 'be'; // Belarusian
    }
    return 'en'; // Default to English
  }

  /// Extract calories/energy value
  static ExtractionResult? _extractCalories(String text) {
    // Multi-language patterns for calories/energy
    final patterns = [
      // English: "Calories: 250 kcal", "Energy 250kcal", "250 cal"
      RegExp(r'\b(?:calories?|energy)\s*:?\s*(\d+(?:\.\d+)?)\s*k?cal\b', caseSensitive: false),

      // Spanish: "Calorías: 250 kcal", "Energía 250kcal"
      RegExp(r'\b(?:calorías|energía)\s*:?\s*(\d+(?:\.\d+)?)\s*k?cal\b', caseSensitive: false),

      // Russian: "Калории: 250 ккал", "Энергетическая ценность 250ккал"
      RegExp(r'\b(?:калории|калорый|энергия|энергетическая ценность)\s*:?\s*(\d+(?:\.\d+)?)\s*к?кал\b', caseSensitive: false),

      // Polish: "Wartość energetyczna: 250 kcal"
      RegExp(r'\b(?:wartość energetyczna|kalorie)\s*:?\s*(\d+(?:\.\d+)?)\s*k?cal\b', caseSensitive: false),

      // Belarusian: "Каларыйнасць: 250 ккал"
      RegExp(r'\b(?:каларыйнасць|энергія)\s*:?\s*(\d+(?:\.\d+)?)\s*к?кал\b', caseSensitive: false),

      // Generic pattern: "250 kcal" near nutrition context
      RegExp(r'\b(\d+(?:\.\d+)?)\s*k?cal\b', caseSensitive: false),
    ];

    // Try kJ (kilojoules) conversion: 1 kcal = 4.184 kJ
    final kjPattern = RegExp(r'\b(?:energy|energía|энергия|energia|энергія)\s*:?\s*(\d+(?:\.\d+)?)\s*kj\b', caseSensitive: false);
    final kjMatch = kjPattern.firstMatch(text);
    if (kjMatch != null) {
      final kj = double.tryParse(kjMatch.group(1)!);
      if (kj != null) {
        final kcal = kj / 4.184;
        return ExtractionResult(value: kcal, confidence: 0.85);
      }
    }

    // Try each pattern
    for (int i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        if (value != null && value > 0 && value < 1000) {
          // Confidence decreases for more generic patterns
          final confidence = i < 5 ? 0.95 : 0.75;
          return ExtractionResult(value: value, confidence: confidence);
        }
      }
    }

    return null;
  }

  /// Extract protein value
  static ExtractionResult? _extractProtein(String text) {
    final patterns = [
      // English: "Protein: 15g", "Protein 15 g"
      RegExp(r'\b(?:protein|proteins)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Spanish: "Proteínas: 15g"
      RegExp(r'\b(?:proteínas|proteina)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Russian: "Белки: 15г"
      RegExp(r'\b(?:белки|белок)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),

      // Polish: "Białko: 15g"
      RegExp(r'\b(?:białko|białka)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Belarusian: "Бялкі: 15г"
      RegExp(r'\b(?:бялкі|бялок)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),
    ];

    return _extractNutrient(text, patterns, maxValue: 100);
  }

  /// Extract fat value
  static ExtractionResult? _extractFat(String text) {
    final patterns = [
      // English: "Fat: 10g", "Total Fat 10g"
      RegExp(r'\b(?:fat|fats|total fat)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Spanish: "Grasas: 10g", "Grasa total 10g"
      RegExp(r'\b(?:grasa|grasas|grasa total)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Russian: "Жиры: 10г"
      RegExp(r'\b(?:жиры|жир)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),

      // Polish: "Tłuszcze: 10g"
      RegExp(r'\b(?:tłuszcze|tłuszcz)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Belarusian: "Тлушчы: 10г"
      RegExp(r'\b(?:тлушчы|тлушч)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),
    ];

    return _extractNutrient(text, patterns, maxValue: 100);
  }

  /// Extract carbohydrates value
  static ExtractionResult? _extractCarbs(String text) {
    final patterns = [
      // English: "Carbs: 30g", "Carbohydrates 30g"
      RegExp(r'\b(?:carb(?:s|ohydrate(?:s)?)?)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Spanish: "Carbohidratos: 30g", "Hidratos de carbono 30g", "Glúcidos 30g"
      RegExp(r'\b(?:carbohidratos|hidratos|glúcidos|glucidos)\s*(?:de carbono)?\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Russian: "Углеводы: 30г"
      RegExp(r'\b(?:углеводы|углевод)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),

      // Polish: "Węglowodany: 30g"
      RegExp(r'\b(?:węglowodany|węglowodan)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // Belarusian: "Вугляводы: 30г"
      RegExp(r'\b(?:вугляводы|вугляв[оа]д)\s*:?\s*(\d+(?:\.\d+)?)\s*г?\b', caseSensitive: false),
    ];

    return _extractNutrient(text, patterns, maxValue: 100);
  }

  /// Extract serving size
  static double? _extractServingSize(String text) {
    final patterns = [
      // "Serving size: 100g", "Portion: 30g"
      RegExp(r'\b(?:serving size|portion|porción|porção)\s*:?\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),

      // "per 100g", "на 100г"
      RegExp(r'\b(?:per|por|на|на кожныя)\s*(\d+(?:\.\d+)?)\s*g\b', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        if (value != null && value > 0 && value <= 1000) {
          return value;
        }
      }
    }

    return null;
  }

  /// Generic nutrient extraction helper
  static ExtractionResult? _extractNutrient(
    String text,
    List<RegExp> patterns, {
    double maxValue = 100,
  }) {
    for (int i = 0; i < patterns.length; i++) {
      final match = patterns[i].firstMatch(text);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        if (value != null && value >= 0 && value <= maxValue) {
          // Higher confidence for more specific patterns
          final confidence = i == 0 ? 0.95 : 0.85;
          return ExtractionResult(value: value, confidence: confidence);
        }
      }
    }

    return null;
  }

  /// Validate extracted nutrition values for reasonableness
  static bool validateNutrition(NutritionExtraction extraction) {
    // Check if values are within reasonable ranges (per 100g)
    if (extraction.calories != null && (extraction.calories! < 0 || extraction.calories! > 900)) {
      return false;
    }
    if (extraction.protein != null && (extraction.protein! < 0 || extraction.protein! > 100)) {
      return false;
    }
    if (extraction.fat != null && (extraction.fat! < 0 || extraction.fat! > 100)) {
      return false;
    }
    if (extraction.carbs != null && (extraction.carbs! < 0 || extraction.carbs! > 100)) {
      return false;
    }

    // Check if macros sum is reasonable (should not exceed ~100g per 100g)
    final macrosSum = (extraction.protein ?? 0) + (extraction.fat ?? 0) + (extraction.carbs ?? 0);
    if (macrosSum > 120) {
      // Allow some tolerance for rounding and fiber content
      return false;
    }

    return true;
  }
}

/// Helper class for extraction results
class ExtractionResult {
  final double value;
  final double confidence;

  ExtractionResult({
    required this.value,
    required this.confidence,
  });
}
