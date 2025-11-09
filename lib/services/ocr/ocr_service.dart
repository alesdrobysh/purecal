import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import '../../models/ocr_result.dart' as models;
import '../../models/nutrition_extraction.dart';
import '../model_download_service.dart';
import 'image_preprocessing_service.dart';
import 'nutrition_text_parser.dart';
import 'llm_nutrition_parser.dart';

/// Service for performing OCR on images using Google ML Kit
/// Supports both regex-based parsing (default) and LLM-based parsing (opt-in)
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePreprocessingService _preprocessingService = ImagePreprocessingService();
  final ModelDownloadService _modelDownloadService = ModelDownloadService();

  // LLM parser (initialized on first use if model is available)
  LLMNutritionParser? _llmParser;
  FlutterGemma? _gemma;

  /// Perform OCR on an image and extract nutrition data
  ///
  /// Steps:
  /// 1. Preprocess image (enhance contrast, sharpen)
  /// 2. Run Google ML Kit text recognition
  /// 3. Parse recognized text for nutrition data (LLM if available, otherwise regex)
  /// 4. Return extraction results with confidence scores
  ///
  /// [imagePath] - Path to the image file
  /// [preprocessImage] - Whether to apply preprocessing (default: true)
  ///
  /// Returns [NutritionExtraction] with parsed data and confidence
  Future<NutritionExtraction> extractNutritionFromImage(
    String imagePath, {
    bool preprocessImage = true,
  }) async {
    try {
      // Step 1: Preprocess image if enabled
      String processedImagePath = imagePath;
      if (preprocessImage) {
        processedImagePath = await _preprocessingService.preprocessForOcr(imagePath);
      }

      // Step 2: Perform OCR
      final ocrResult = await recognizeText(processedImagePath);

      // Step 3: Parse nutrition data from OCR text
      // Check if LLM model is available and use it, otherwise fall back to regex
      NutritionExtraction nutritionData;

      final useAI = await _modelDownloadService.isModelDownloaded();
      if (useAI) {
        try {
          // Use LLM parser for universal language support
          nutritionData = await _parseWithLLM(ocrResult.fullText);
        } catch (e) {
          // If LLM parsing fails, fall back to regex
          print('LLM parsing failed, falling back to regex: $e');
          nutritionData = NutritionTextParser.parse(ocrResult.fullText);
        }
      } else {
        // Use regex parser (default)
        nutritionData = NutritionTextParser.parse(ocrResult.fullText);
      }

      // Clean up temporary preprocessed image
      if (preprocessImage && processedImagePath != imagePath) {
        try {
          await File(processedImagePath).delete();
        } catch (e) {
          // Ignore deletion errors
        }
      }

      return nutritionData;
    } catch (e) {
      throw OcrException('Failed to extract nutrition data: $e');
    }
  }

  /// Parse nutrition data using LLM (AI-powered, universal language support)
  Future<NutritionExtraction> _parseWithLLM(String ocrText) async {
    // Initialize LLM parser if not already initialized
    if (_llmParser == null || _gemma == null) {
      _gemma = FlutterGemma();
      _llmParser = LLMNutritionParser(_gemma!);

      final modelPath = await _modelDownloadService.getModelPath();
      await _llmParser!.initialize(modelPath);
    }

    return await _llmParser!.parse(ocrText);
  }

  /// Recognize text from an image using Google ML Kit
  ///
  /// Returns raw OCR results with text blocks and positions
  Future<models.OcrResult> recognizeText(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Convert ML Kit results to our OcrResult model
      final textBlocks = <models.TextBlock>[];
      int lineNumber = 0;

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          // Calculate average confidence for the line
          double totalConfidence = 0;
          int elementCount = 0;

          for (final element in line.elements) {
            // ML Kit doesn't provide confidence scores directly
            // We estimate based on text quality and context
            totalConfidence += 0.9; // Default high confidence for ML Kit
            elementCount++;
          }

          final avgConfidence = elementCount > 0 ? totalConfidence / elementCount : 0.85;

          // Create bounding box from line corners
          final boundingBox = _createBoundingBox(line.boundingBox);

          textBlocks.add(
            models.TextBlock(
              text: line.text,
              boundingBox: boundingBox,
              confidence: avgConfidence,
              lineNumber: lineNumber++,
            ),
          );
        }
      }

      // Calculate overall confidence (average of all blocks)
      final overallConfidence = textBlocks.isNotEmpty
          ? textBlocks.map((b) => b.confidence).reduce((a, b) => a + b) / textBlocks.length
          : 0.0;

      // Combine all text
      final fullText = textBlocks.map((b) => b.text).join('\n');

      return models.OcrResult(
        textBlocks: textBlocks,
        confidence: overallConfidence,
        fullText: fullText,
        engine: models.OcrEngine.googleMLKit,
      );
    } catch (e) {
      throw OcrException('Text recognition failed: $e');
    }
  }

  /// Recognize text from a specific region of the image
  ///
  /// Useful when nutrition table detection provides bounding box
  Future<models.OcrResult> recognizeTextInRegion(
    String imagePath, {
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    try {
      // Crop image to the specified region
      final croppedImagePath = await _preprocessingService.cropToRegion(
        imagePath,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      // Perform OCR on the cropped region
      final result = await recognizeText(croppedImagePath);

      // Clean up temporary cropped image
      try {
        await File(croppedImagePath).delete();
      } catch (e) {
        // Ignore deletion errors
      }

      return result;
    } catch (e) {
      throw OcrException('Region OCR failed: $e');
    }
  }

  /// Create bounding box from ML Kit Rect
  models.BoundingBox _createBoundingBox(Rect rect) {
    return models.BoundingBox(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  /// Get suggested preprocessing settings based on image quality
  ///
  /// Analyzes image and returns recommended preprocessing flags
  Future<PreprocessingSettings> analyzeImageQuality(String imagePath) async {
    // TODO: Implement image quality analysis
    // For now, return default settings
    return PreprocessingSettings(
      shouldPreprocess: true,
      shouldEnhanceContrast: true,
      shouldSharpen: true,
      shouldDenoise: false,
    );
  }

  /// Dispose of resources
  void dispose() {
    _textRecognizer.close();
    _llmParser?.dispose();
  }
}

/// Preprocessing settings recommendations
class PreprocessingSettings {
  final bool shouldPreprocess;
  final bool shouldEnhanceContrast;
  final bool shouldSharpen;
  final bool shouldDenoise;

  PreprocessingSettings({
    required this.shouldPreprocess,
    required this.shouldEnhanceContrast,
    required this.shouldSharpen,
    required this.shouldDenoise,
  });
}

/// Custom exception for OCR errors
class OcrException implements Exception {
  final String message;

  OcrException(this.message);

  @override
  String toString() => 'OcrException: $message';
}
