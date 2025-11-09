import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GemmaService {
  static const MODEL_TYPE = ModelType.qwen25;
  static const MODEL_URL =
      'https://huggingface.co/litert-community/Qwen2.5-1.5B-Instruct/resolve/main/qwen2.5-1.5b-instruct-cpu.task';

  GemmaModel? _model;
  GemmaChatSession? _activeChat;

  // Check if model is downloaded
  Future<bool> isModelInstalled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('gemma_model_installed') ?? false;
  }

  // Download model with progress callback
  Future<void> downloadModel({
    required Function(double progress) onProgress,
    String? huggingfaceToken,
  }) async {
    try {
      await FlutterGemma.installModel(modelType: MODEL_TYPE)
          .fromNetwork(MODEL_URL, token: huggingfaceToken)
          .withProgress((progress) => onProgress(progress / 100.0))
          .install();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('gemma_model_installed', true);
    } catch (e) {
      throw Exception('Model download failed: $e');
    }
  }

  // Load model into memory
  Future<void> loadModel() async {
    if (_model != null) return; // Already loaded

    try {
      _model = await FlutterGemma.getActiveModel(
        maxTokens: 2048, // Context window
        preferredBackend: PreferredBackend.gpu, // Use GPU if available
        temperature: 0.7, // Balanced creativity
        topK: 40,
        topP: 0.9,
      );

      _activeChat = await _model!.createChat();
    } catch (e) {
      throw Exception('Model load failed: $e');
    }
  }

  // Unload model from memory
  Future<void> unloadModel() async {
    _activeChat = null;
    _model = null;
    // MediaPipe handles cleanup automatically
  }

  // Generate response with streaming
  Stream<String> generateResponse(String prompt) async* {
    if (_activeChat == null) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    try {
      // Add user message to chat history
      await _activeChat!.addQueryChunk(
        Message.text(text: prompt, isUser: true),
      );

      // Generate response (flutter_gemma returns full response, not streamed)
      final response = await _activeChat!.generateChatResponse();

      // Simulate streaming for UI smoothness
      final text = response.text ?? '';
      const chunkSize = 3; // Characters per yield

      for (int i = 0; i < text.length; i += chunkSize) {
        final end =
            (i + chunkSize > text.length) ? text.length : i + chunkSize;
        yield text.substring(i, end);

        // Small delay for visual streaming effect
        await Future.delayed(Duration(milliseconds: 20));
      }
    } catch (e) {
      throw Exception('Generation failed: $e');
    }
  }

  // Clear chat history
  Future<void> clearHistory() async {
    if (_model != null) {
      _activeChat = await _model!.createChat(); // New session
    }
  }

  // Delete downloaded model
  Future<void> deleteModel() async {
    await unloadModel();

    // flutter_gemma doesn't expose delete API yet
    // Manual cleanup:
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gemma_model_installed', false);

    // Note: Model files remain on disk. User can clear via app settings.
  }

  // Get model memory usage estimate
  int get estimatedMemoryMB => _model != null ? 1200 : 0; // ~1.2GB when loaded
}
