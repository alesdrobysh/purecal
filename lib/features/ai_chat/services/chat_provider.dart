import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/chat_message.dart';
import 'gemma_service.dart';
import 'nutrition_prompt_builder.dart';

enum ModelStatus { notDownloaded, downloading, downloaded, loading, loaded, error }

class ChatProvider extends ChangeNotifier {
  final GemmaService _gemmaService;
  final NutritionPromptBuilder _promptBuilder;
  final Database _database;

  List<ChatMessage> _messages = [];
  ModelStatus _modelStatus = ModelStatus.notDownloaded;
  double _downloadProgress = 0.0;
  bool _isGenerating = false;
  String? _error;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  ModelStatus get modelStatus => _modelStatus;
  double get downloadProgress => _downloadProgress;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  bool get isReady => _modelStatus == ModelStatus.loaded;

  ChatProvider({
    required GemmaService gemmaService,
    required NutritionPromptBuilder promptBuilder,
    required Database database,
  })  : _gemmaService = gemmaService,
        _promptBuilder = promptBuilder,
        _database = database {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if model is installed
    final installed = await _gemmaService.isModelInstalled();
    _modelStatus =
        installed ? ModelStatus.downloaded : ModelStatus.notDownloaded;

    // Load chat history
    await _loadChatHistory();

    // Auto-load model if installed
    if (installed) {
      await loadModelIntoMemory();
    }

    notifyListeners();
  }

  Future<void> _loadChatHistory() async {
    try {
      final results = await _database.query(
        'ai_chat_messages',
        orderBy: 'timestamp DESC',
        limit: 50,
      );
      _messages =
          results.map((m) => ChatMessage.fromMap(m)).toList().reversed.toList();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
      // Table might not exist yet, ignore error
    }
  }

  // Download model
  Future<void> downloadModel({String? huggingfaceToken}) async {
    if (_modelStatus == ModelStatus.downloading) return;

    _modelStatus = ModelStatus.downloading;
    _downloadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      await _gemmaService.downloadModel(
        onProgress: (progress) {
          _downloadProgress = progress;
          notifyListeners();
        },
        huggingfaceToken: huggingfaceToken,
      );

      _modelStatus = ModelStatus.downloaded;
      _downloadProgress = 1.0;
    } catch (e) {
      _modelStatus = ModelStatus.error;
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Load model into memory
  Future<void> loadModelIntoMemory() async {
    if (_modelStatus == ModelStatus.loaded ||
        _modelStatus == ModelStatus.loading) {
      return;
    }

    _modelStatus = ModelStatus.loading;
    _error = null;
    notifyListeners();

    try {
      await _gemmaService.loadModel();
      _modelStatus = ModelStatus.loaded;
    } catch (e) {
      _modelStatus = ModelStatus.error;
      _error = 'Failed to load model: $e';
    } finally {
      notifyListeners();
    }
  }

  // Unload from memory (free RAM)
  Future<void> unloadModel() async {
    await _gemmaService.unloadModel();
    _modelStatus = ModelStatus.downloaded;
    notifyListeners();
  }

  // Send message and get response
  Future<void> sendMessage(String userInput,
      {Map<String, dynamic>? nutritionContext}) async {
    if (!isReady || _isGenerating || userInput.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: userInput,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isGenerating = true;
    _error = null;
    notifyListeners();

    // Save user message
    await _database.insert('ai_chat_messages', userMessage.toMap());

    try {
      // Build context-aware prompt
      final prompt = await _promptBuilder.buildPrompt(
        userInput: userInput,
        chatHistory:
            _messages.where((m) => m.role != MessageRole.system).toList(),
        nutritionContext: nutritionContext,
      );

      // Start streaming response
      final assistantMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: MessageRole.assistant,
        content: '',
        timestamp: DateTime.now(),
        isStreaming: true,
      );
      _messages.add(assistantMessage);
      notifyListeners();

      // Stream tokens
      await for (final chunk in _gemmaService.generateResponse(prompt)) {
        final index = _messages.length - 1;
        _messages[index] = ChatMessage(
          id: assistantMessage.id,
          role: MessageRole.assistant,
          content: _messages[index].content + chunk,
          timestamp: assistantMessage.timestamp,
          isStreaming: true,
        );
        notifyListeners();
      }

      // Mark complete
      final index = _messages.length - 1;
      _messages[index] = _messages[index].copyWith(isStreaming: false);

      // Save assistant message
      await _database.insert('ai_chat_messages', _messages[index].toMap());
    } catch (e) {
      _error = e.toString();
      _messages.removeLast(); // Remove incomplete message
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  // Clear chat history
  Future<void> clearHistory() async {
    await _database.delete('ai_chat_messages');
    await _gemmaService.clearHistory();
    _messages.clear();
    notifyListeners();
  }

  // Delete model
  Future<void> deleteModel() async {
    await unloadModel();
    await _gemmaService.deleteModel();
    _modelStatus = ModelStatus.notDownloaded;
    notifyListeners();
  }
}
