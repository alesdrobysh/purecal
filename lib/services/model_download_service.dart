import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for managing LLM model downloads
/// Handles downloading, storing, and deleting AI models for nutrition parsing
class ModelDownloadService {
  // Model configuration
  static const String MODEL_URL =
      'https://huggingface.co/google/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-q4_k_m.gguf';
  static const String MODEL_FILENAME = 'gemma-2b-it-q4.gguf';
  static const int MODEL_SIZE_BYTES = 1610612736; // ~1.5 GB

  final Dio _dio = Dio();

  /// Check if the model is already downloaded
  Future<bool> isModelDownloaded() async {
    try {
      final modelPath = await _getModelPath();
      final file = File(modelPath);

      if (!await file.exists()) {
        return false;
      }

      // Verify file size is reasonable (at least 1GB)
      final fileSize = await file.length();
      return fileSize > 1000000000; // > 1 GB indicates complete download
    } catch (e) {
      return false;
    }
  }

  /// Get the size of the downloaded model in bytes
  Future<int> getModelSize() async {
    try {
      final modelPath = await _getModelPath();
      final file = File(modelPath);

      if (!await file.exists()) {
        return 0;
      }

      return await file.length();
    } catch (e) {
      return 0;
    }
  }

  /// Download the AI model with progress tracking
  Future<void> downloadModel({
    required Function(double progress, int received, int total) onProgress,
    CancelToken? cancelToken,
  }) async {
    final modelPath = await _getModelPath();
    final modelDir = path.dirname(modelPath);

    // Create models directory if it doesn't exist
    final dir = Directory(modelDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    try {
      await _dio.download(
        MODEL_URL,
        modelPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress, received, total);
          }
        },
        cancelToken: cancelToken,
        options: Options(
          headers: {
            HttpHeaders.acceptEncodingHeader: '*', // Accept any encoding
          },
          receiveTimeout: const Duration(hours: 1), // Long timeout for large file
        ),
      );

      // Verify download completed successfully
      final downloaded = await isModelDownloaded();
      if (!downloaded) {
        throw Exception('Model download verification failed');
      }
    } catch (e) {
      // Clean up partial download
      final file = File(modelPath);
      if (await file.exists()) {
        await file.delete();
      }
      rethrow;
    }
  }

  /// Delete the downloaded model to free up space
  Future<void> deleteModel() async {
    try {
      final modelPath = await _getModelPath();
      final file = File(modelPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete model: $e');
    }
  }

  /// Get the full path where the model is/will be stored
  Future<String> getModelPath() async {
    return await _getModelPath();
  }

  /// Internal method to get model path
  Future<String> _getModelPath() async {
    final appSupportDir = await getApplicationSupportDirectory();
    final modelDir = path.join(appSupportDir.path, 'models');
    return path.join(modelDir, MODEL_FILENAME);
  }

  /// Format bytes to human-readable size
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Get estimated download time based on connection speed
  static String estimateDownloadTime(double speedMBps) {
    final sizeGB = MODEL_SIZE_BYTES / (1024 * 1024 * 1024);
    final sizeMB = sizeGB * 1024;
    final seconds = sizeMB / speedMBps;

    if (seconds < 60) return '< 1 minute';
    if (seconds < 3600) return '~${(seconds / 60).ceil()} minutes';
    return '~${(seconds / 3600).toStringAsFixed(1)} hours';
  }
}
