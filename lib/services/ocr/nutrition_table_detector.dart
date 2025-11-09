import 'dart:io';
import 'package:flutter_vision/flutter_vision.dart';

/// Service for detecting nutrition tables in images using YOLO
/// Uses OpenFoodFacts nutrition-table-yolo model
class NutritionTableDetector {
  FlutterVision? _vision;
  bool _isModelLoaded = false;

  /// Initialize the YOLO model
  ///
  /// Must be called before using detection methods
  Future<void> initialize() async {
    try {
      _vision = FlutterVision();

      // Load the YOLOv8 nutrition table detection model
      await _vision!.loadYoloModel(
        labels: 'assets/models/nutrition_table_labels.txt',
        modelPath: 'assets/models/nutrition_table_yolo.tflite',
        modelVersion: 'yolov8',
        quantization: false,
        numThreads: 2,
        useGpu: true,
      );

      _isModelLoaded = true;
    } catch (e) {
      throw NutritionTableDetectorException('Failed to initialize model: $e');
    }
  }

  /// Detect nutrition tables in an image
  ///
  /// [imagePath] - Path to the image file
  /// [confidenceThreshold] - Minimum confidence score (0.0-1.0)
  ///
  /// Returns list of detected nutrition table regions
  Future<List<NutritionTableRegion>> detectNutritionTables(
    String imagePath, {
    double confidenceThreshold = 0.5,
  }) async {
    if (!_isModelLoaded || _vision == null) {
      throw NutritionTableDetectorException('Model not initialized. Call initialize() first.');
    }

    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw NutritionTableDetectorException('Image file not found: $imagePath');
      }

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Perform YOLO detection
      final results = await _vision!.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: 640,
        imageWidth: 640,
        iouThreshold: 0.4,
        confThreshold: confidenceThreshold,
        classThreshold: confidenceThreshold,
      );

      // Convert YOLO results to NutritionTableRegion objects
      final regions = <NutritionTableRegion>[];

      for (final result in results) {
        // Extract bounding box coordinates
        final box = result['box'];
        final confidence = result['conf'] ?? 0.0;

        regions.add(
          NutritionTableRegion(
            x: (box[0] as num).toDouble(),
            y: (box[1] as num).toDouble(),
            width: (box[2] as num).toDouble(),
            height: (box[3] as num).toDouble(),
            confidence: confidence,
          ),
        );
      }

      // Sort by confidence (highest first)
      regions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return regions;
    } catch (e) {
      throw NutritionTableDetectorException('Detection failed: $e');
    }
  }

  /// Detect the best nutrition table region
  ///
  /// Returns the region with highest confidence, or null if none found
  Future<NutritionTableRegion?> detectBestNutritionTable(
    String imagePath, {
    double confidenceThreshold = 0.5,
  }) async {
    final regions = await detectNutritionTables(
      imagePath,
      confidenceThreshold: confidenceThreshold,
    );

    return regions.isNotEmpty ? regions.first : null;
  }

  /// Check if model is ready for detection
  bool get isReady => _isModelLoaded && _vision != null;

  /// Dispose of resources
  Future<void> dispose() async {
    if (_vision != null) {
      await _vision!.closeYoloModel();
      _vision = null;
      _isModelLoaded = false;
    }
  }
}

/// Represents a detected nutrition table region in an image
class NutritionTableRegion {
  /// X coordinate of top-left corner
  final double x;

  /// Y coordinate of top-left corner
  final double y;

  /// Width of the region
  final double width;

  /// Height of the region
  final double height;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  NutritionTableRegion({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.confidence,
  });

  /// Get center point of the region
  (double x, double y) get center => (x + width / 2, y + height / 2);

  /// Get area of the region
  double get area => width * height;

  /// Check if region is valid (has positive dimensions)
  bool get isValid => width > 0 && height > 0;

  @override
  String toString() {
    return 'NutritionTableRegion(x: $x, y: $y, w: $width, h: $height, conf: ${(confidence * 100).toStringAsFixed(0)}%)';
  }

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'confidence': confidence,
    };
  }

  /// Create from map
  factory NutritionTableRegion.fromMap(Map<String, dynamic> map) {
    return NutritionTableRegion(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      width: (map['width'] as num).toDouble(),
      height: (map['height'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
    );
  }
}

/// Custom exception for nutrition table detection errors
class NutritionTableDetectorException implements Exception {
  final String message;

  NutritionTableDetectorException(this.message);

  @override
  String toString() => 'NutritionTableDetectorException: $message';
}
