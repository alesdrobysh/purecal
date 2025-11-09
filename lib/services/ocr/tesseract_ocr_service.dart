import 'dart:io';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import '../../models/ocr_result.dart' as models;
import '../../models/nutrition_extraction.dart';
import 'image_preprocessing_service.dart';
import 'nutrition_text_parser.dart';

/// Tesseract OCR service as fallback engine
/// Used when Google ML Kit fails or for offline-first scenarios
class TesseractOcrService {
  final ImagePreprocessingService _preprocessingService = ImagePreprocessingService();

  /// Extract nutrition data using Tesseract OCR
  ///
  /// Fallback method when primary OCR engine fails
  ///
  /// [imagePath] - Path to the image file
  /// [language] - Tesseract language code (default: 'eng')
  /// [preprocessImage] - Whether to apply preprocessing
  ///
  /// Returns [NutritionExtraction] with parsed data
  Future<NutritionExtraction> extractNutritionFromImage(
    String imagePath, {
    String language = 'eng',
    bool preprocessImage = true,
  }) async {
    try {
      // Preprocess image if enabled
      String processedImagePath = imagePath;
      if (preprocessImage) {
        processedImagePath = await _preprocessingService.preprocessForOcr(imagePath);
      }

      // Perform OCR
      final ocrResult = await recognizeText(processedImagePath, language: language);

      // Parse nutrition data
      final nutritionData = NutritionTextParser.parse(ocrResult.fullText);

      // Clean up
      if (preprocessImage && processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
        } catch (e) {
          // Ignore
        }
      }

      return nutritionData;
    } catch (e) {
      throw TesseractException('Tesseract extraction failed: $e');
    }
  }

  /// Recognize text using Tesseract OCR engine
  ///
  /// [imagePath] - Path to the image
  /// [language] - Language code(s), e.g., 'eng', 'spa', 'rus', 'pol'
  ///              Multiple languages can be specified with '+': 'eng+spa'
  ///
  /// Returns [OcrResult] with recognized text
  Future<models.OcrResult> recognizeText(
    String imagePath, {
    String language = 'eng',
  }) async {
    try {
      // Tesseract OCR performs text recognition
      final text = await FlutterTesseractOcr.extractText(
        imagePath,
        language: language,
        args: {
          "psm": "3", // Page segmentation mode: 3 = Automatic page segmentation
          "preserve_interword_spaces": "1",
        },
      );

      // Tesseract doesn't provide detailed position information easily
      // Create a single text block with the full text
      final textBlock = models.TextBlock(
        text: text,
        boundingBox: models.BoundingBox(x: 0, y: 0, width: 0, height: 0),
        confidence: 0.80, // Default confidence for Tesseract
        lineNumber: 0,
      );

      return models.OcrResult(
        textBlocks: [textBlock],
        confidence: 0.80,
        fullText: text,
        engine: models.OcrEngine.tesseract,
      );
    } catch (e) {
      throw TesseractException('Tesseract recognition failed: $e');
    }
  }

  /// Extract text with multiple language support
  ///
  /// Useful for multilingual nutrition labels
  Future<models.OcrResult> recognizeTextMultiLanguage(
    String imagePath, {
    List<String> languages = const ['eng', 'spa', 'rus', 'pol'],
  }) async {
    final languageString = languages.join('+');
    return await recognizeText(imagePath, language: languageString);
  }

  /// Get list of available Tesseract languages on device
  ///
  /// Note: Languages need to be downloaded/bundled with the app
  Future<List<String>> getAvailableLanguages() async {
    // TODO: Implement language detection
    // For now, return common languages we support
    return ['eng', 'spa', 'rus', 'pol'];
  }
}

/// Custom exception for Tesseract errors
class TesseractException implements Exception {
  final String message;

  TesseractException(this.message);

  @override
  String toString() => 'TesseractException: $message';
}
