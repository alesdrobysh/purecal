import 'dart:convert';
import 'package:flutter_gemma/flutter_gemma.dart';
import '../../models/nutrition_extraction.dart';

/// Service for parsing nutrition information using Local LLM
/// Uses Gemma 2B model for universal language support
class LLMNutritionParser {
  final FlutterGemma _llm;
  bool _isInitialized = false;

  LLMNutritionParser(this._llm);

  /// Initialize the LLM with the model
  Future<void> initialize(String modelPath) async {
    if (_isInitialized) return;

    try {
      await _llm.init(
        modelPath: modelPath,
        maxTokens: 512,
        temperature: 0.1, // Low temperature for consistent extraction
        topK: 40,
        topP: 0.95,
      );
      _isInitialized = true;
    } catch (e) {
      throw LLMParserException('Failed to initialize LLM: $e');
    }
  }

  /// Parse nutrition data from OCR text using LLM
  ///
  /// The LLM will:
  /// 1. Extract calories/energy (convert kJ to kcal if needed)
  /// 2. Extract protein in grams
  /// 3. Extract fat in grams
  /// 4. Extract carbohydrates in grams
  /// 5. Assign confidence scores
  /// 6. Detect the language
  Future<NutritionExtraction> parse(String ocrText) async {
    if (!_isInitialized) {
      throw LLMParserException('LLM not initialized. Call initialize() first.');
    }

    try {
      final prompt = _buildPrompt(ocrText);
      final response = await _llm.generateResponse(prompt);

      // Parse JSON response
      final extraction = _parseResponse(response, ocrText);

      return extraction;
    } catch (e) {
      throw LLMParserException('Failed to parse nutrition data: $e');
    }
  }

  /// Build the prompt for the LLM
  String _buildPrompt(String ocrText) {
    return '''You are a nutrition label parser AI. Extract nutrition information per 100g from the following text.

Text from nutrition label:
"""
$ocrText
"""

Instructions:
1. Find calories/energy value. If in kJ (kilojoules), convert to kcal using: 1 kcal = 4.184 kJ
2. Find protein in grams (g)
3. Find fat/lipids in grams (g)
4. Find carbohydrates/carbs in grams (g)
5. Assign confidence score (0.0-1.0) for each value based on:
   - 1.0 = Exact match with clear label
   - 0.9 = Clear match with standard format
   - 0.8 = Match but slight uncertainty
   - 0.7 = Ambiguous or unclear
   - 0.5 or less = Very uncertain
6. Detect the language of the label
7. If a value is not found, set it to null

IMPORTANT: Output ONLY valid JSON. No markdown, no explanation, just JSON.

Output format:
{
  "calories": <number or null>,
  "protein": <number or null>,
  "fat": <number or null>,
  "carbs": <number or null>,
  "calories_confidence": <0.0-1.0>,
  "protein_confidence": <0.0-1.0>,
  "fat_confidence": <0.0-1.0>,
  "carbs_confidence": <0.0-1.0>,
  "detected_language": "<language name>"
}

JSON:''';
  }

  /// Parse the LLM response and create NutritionExtraction object
  NutritionExtraction _parseResponse(String response, String sourceText) {
    try {
      // Clean up response (remove markdown code blocks if present)
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();

      // Parse JSON
      final json = jsonDecode(cleanedResponse);

      // Extract values with null safety
      final calories = _parseNumber(json['calories']);
      final protein = _parseNumber(json['protein']);
      final fat = _parseNumber(json['fat']);
      final carbs = _parseNumber(json['carbs']);

      final caloriesConfidence = _parseNumber(json['calories_confidence']) ?? 0.0;
      final proteinConfidence = _parseNumber(json['protein_confidence']) ?? 0.0;
      final fatConfidence = _parseNumber(json['fat_confidence']) ?? 0.0;
      final carbsConfidence = _parseNumber(json['carbs_confidence']) ?? 0.0;

      final language = json['detected_language']?.toString();

      return NutritionExtraction(
        calories: calories,
        protein: protein,
        fat: fat,
        carbs: carbs,
        caloriesConfidence: caloriesConfidence.clamp(0.0, 1.0),
        proteinConfidence: proteinConfidence.clamp(0.0, 1.0),
        fatConfidence: fatConfidence.clamp(0.0, 1.0),
        carbsConfidence: carbsConfidence.clamp(0.0, 1.0),
        sourceText: sourceText,
        language: language,
      );
    } catch (e) {
      // If JSON parsing fails, return empty extraction with error
      return NutritionExtraction(
        calories: null,
        protein: null,
        fat: null,
        carbs: null,
        caloriesConfidence: 0.0,
        proteinConfidence: 0.0,
        fatConfidence: 0.0,
        carbsConfidence: 0.0,
        sourceText: sourceText,
        language: null,
      );
    }
  }

  /// Parse a number from dynamic JSON value
  double? _parseNumber(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    // Note: flutter_gemma doesn't have explicit dispose in v2.0
    // The underlying native resources are managed automatically
    _isInitialized = false;
  }
}

/// Custom exception for LLM parser errors
class LLMParserException implements Exception {
  final String message;

  LLMParserException(this.message);

  @override
  String toString() => 'LLMParserException: $message';
}
