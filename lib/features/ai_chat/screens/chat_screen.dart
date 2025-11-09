import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/download_progress_widget.dart';
import '../../../services/diary_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();

    // Get nutrition context from DiaryProvider
    final diaryProvider = context.read<DiaryProvider>();
    final nutritionContext = {
      'todayCalories': diaryProvider.dailySummary.calories,
      'calorieGoal': diaryProvider.userGoals?.caloriesGoal,
      'todayProtein': diaryProvider.dailySummary.proteins,
      'proteinGoal': diaryProvider.userGoals?.proteinsGoal,
    };

    chatProvider.sendMessage(text, nutritionContext: nutritionContext);
    _textController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Nutrition Assistant'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              if (provider.modelStatus == ModelStatus.loaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'clear') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Chat History'),
                          content: const Text(
                              'This will delete all chat messages. Continue?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await provider.clearHistory();
                      }
                    } else if (value == 'unload') {
                      await provider.unloadModel();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Model unloaded from memory')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'clear',
                      child: Text('Clear chat history'),
                    ),
                    const PopupMenuItem(
                      value: 'unload',
                      child: Text('Unload model (free RAM)'),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          // Show download UI if model not ready
          if (provider.modelStatus == ModelStatus.notDownloaded ||
              provider.modelStatus == ModelStatus.downloading) {
            return const DownloadProgressWidget();
          }

          // Show loading UI
          if (provider.modelStatus == ModelStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading AI model...'),
                ],
              ),
            );
          }

          // Show error
          if (provider.modelStatus == ModelStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadModelIntoMemory(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Chat UI
          return Column(
            children: [
              // Experimental warning banner
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.science,
                        size: 16, color: Colors.orange.shade900),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Experimental feature - not medical advice',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

              // Messages list
              Expanded(
                child: provider.messages.isEmpty
                    ? const Center(
                        child: Text(
                          'Ask me about nutrition!\nAll conversations stay on your device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) {
                          return ChatBubble(message: provider.messages[index]);
                        },
                      ),
              ),

              // Input field
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        enabled: !provider.isGenerating,
                        decoration: const InputDecoration(
                          hintText: 'Ask about nutrition...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: provider.isGenerating
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      onPressed: provider.isGenerating ? null : _sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
