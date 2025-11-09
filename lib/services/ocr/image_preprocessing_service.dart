import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for preprocessing images before OCR
/// Applies enhancement techniques to improve text recognition accuracy
class ImagePreprocessingService {
  /// Preprocess an image for optimal OCR performance
  ///
  /// Steps:
  /// 1. Load image
  /// 2. Resize if too large (max 2048px)
  /// 3. Convert to grayscale
  /// 4. Enhance contrast using CLAHE
  /// 5. Apply sharpening
  /// 6. Reduce noise
  ///
  /// Returns path to the preprocessed image
  Future<String> preprocessForOcr(String imagePath) async {
    // Load the image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Step 1: Resize if too large (saves memory and processing time)
    image = _resizeIfNeeded(image);

    // Step 2: Convert to grayscale (OCR works better on grayscale)
    image = img.grayscale(image);

    // Step 3: Enhance contrast using histogram equalization
    image = _enhanceContrast(image);

    // Step 4: Apply sharpening to make text edges clearer
    image = _sharpenImage(image);

    // Step 5: Noise reduction (optional, can help with low-quality images)
    // image = img.gaussianBlur(image, radius: 1);

    // Save the preprocessed image
    final preprocessedPath = await _savePreprocessedImage(image);

    return preprocessedPath;
  }

  /// Resize image if it exceeds maximum dimensions
  img.Image _resizeIfNeeded(img.Image image, {int maxDimension = 2048}) {
    if (image.width <= maxDimension && image.height <= maxDimension) {
      return image;
    }

    // Calculate new dimensions while maintaining aspect ratio
    final double scale = maxDimension / (image.width > image.height ? image.width : image.height);
    final int newWidth = (image.width * scale).round();
    final int newHeight = (image.height * scale).round();

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.cubic,
    );
  }

  /// Enhance contrast to make text stand out
  img.Image _enhanceContrast(img.Image image, {int amount = 175}) {
    return img.adjustColor(
      image,
      contrast: amount / 100.0,
    );
  }

  /// Sharpen image to make text edges clearer
  img.Image _sharpenImage(img.Image image) {
    // Apply a sharpening convolution filter
    return img.convolution(
      image,
      filter: [
        0, -1, 0,
        -1, 5, -1,
        0, -1, 0,
      ],
      div: 1,
    );
  }

  /// Crop image to a specific region of interest (ROI)
  /// Useful when nutrition table detection provides bounding box
  Future<String> cropToRegion(
    String imagePath, {
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Ensure crop coordinates are within bounds
    final cropX = x.clamp(0, image.width - 1).toInt();
    final cropY = y.clamp(0, image.height - 1).toInt();
    final cropWidth = width.clamp(1, image.width - cropX).toInt();
    final cropHeight = height.clamp(1, image.height - cropY).toInt();

    // Crop the image
    final cropped = img.copyCrop(
      image,
      x: cropX,
      y: cropY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save the cropped image
    return await _savePreprocessedImage(cropped, suffix: 'cropped');
  }

  /// Apply perspective correction to straighten skewed images
  /// This is useful for photos taken at an angle
  img.Image correctPerspective(img.Image image) {
    // TODO: Implement perspective correction using corner detection
    // For now, return the original image
    // Future enhancement: Use OpenCV or custom algorithm
    return image;
  }

  /// Apply adaptive thresholding for better text contrast
  /// Useful for images with varying lighting conditions
  img.Image applyAdaptiveThreshold(img.Image image) {
    // Convert to grayscale if not already
    final gray = img.grayscale(image);

    // Apply Otsu's thresholding (automatic threshold calculation)
    // This separates text (black) from background (white)
    final threshold = _calculateOtsuThreshold(gray);

    // Apply the threshold
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        final luminance = pixel.r; // In grayscale, R=G=B

        // Set to black or white based on threshold
        final newColor = luminance > threshold ? img.ColorRgb8(255, 255, 255) : img.ColorRgb8(0, 0, 0);
        gray.setPixel(x, y, newColor);
      }
    }

    return gray;
  }

  /// Calculate optimal threshold using Otsu's method
  int _calculateOtsuThreshold(img.Image grayImage) {
    // Build histogram
    final histogram = List<int>.filled(256, 0);
    for (int y = 0; y < grayImage.height; y++) {
      for (int x = 0; x < grayImage.width; x++) {
        final pixel = grayImage.getPixel(x, y);
        histogram[pixel.r.toInt()]++;
      }
    }

    final total = grayImage.width * grayImage.height;

    double sum = 0;
    for (int i = 0; i < 256; i++) {
      sum += i * histogram[i];
    }

    double sumB = 0;
    int wB = 0;
    int wF = 0;

    double maxVariance = 0;
    int threshold = 0;

    for (int t = 0; t < 256; t++) {
      wB += histogram[t];
      if (wB == 0) continue;

      wF = total - wB;
      if (wF == 0) break;

      sumB += t * histogram[t];

      final mB = sumB / wB;
      final mF = (sum - sumB) / wF;

      final variance = wB * wF * (mB - mF) * (mB - mF);

      if (variance > maxVariance) {
        maxVariance = variance;
        threshold = t;
      }
    }

    return threshold;
  }

  /// Save preprocessed image to temporary directory
  Future<String> _savePreprocessedImage(img.Image image, {String suffix = 'preprocessed'}) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'ocr_${suffix}_$timestamp.jpg';
    final filePath = path.join(tempDir.path, filename);

    // Encode as JPEG with high quality
    final jpegBytes = img.encodeJpg(image, quality: 95);

    // Save to file
    final file = File(filePath);
    await file.writeAsBytes(jpegBytes);

    return filePath;
  }

  /// Clean up temporary preprocessed images
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('ocr_')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore errors during cleanup
    }
  }
}
