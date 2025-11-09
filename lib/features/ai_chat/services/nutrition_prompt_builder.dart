import '../models/chat_message.dart';

class NutritionPromptBuilder {
  static const int MAX_HISTORY_MESSAGES = 6; // Last 3 exchanges

  Future<String> buildPrompt({
    required String userInput,
    required List<ChatMessage> chatHistory,
    Map<String, dynamic>? nutritionContext,
  }) async {
    final systemPrompt = _buildSystemPrompt(nutritionContext);
    final historyText = _formatHistory(chatHistory);

    // Qwen2.5 chat template format
    return '''<|im_start|>system
$systemPrompt<|im_end|>
$historyText<|im_start|>user
$userInput<|im_end|>
<|im_start|>assistant
''';
  }

  String _buildSystemPrompt(Map<String, dynamic>? context) {
    final buffer = StringBuffer();
    buffer.writeln(
        'You are a helpful nutrition assistant for PureCal, a privacy-focused food tracking app.');
    buffer.writeln('Guidelines:');
    buffer.writeln('- Keep responses concise (2-3 sentences max)');
    buffer.writeln('- Focus on practical, actionable nutrition advice');
    buffer.writeln(
        '- Never provide medical diagnoses or replace professional medical advice');
    buffer.writeln(
        '- All data is local and private - user has full control');

    if (context != null) {
      buffer.writeln('\nUser context today:');
      if (context['todayCalories'] != null) {
        buffer.writeln(
            '- Calories: ${context['todayCalories']} / ${context['calorieGoal'] ?? '?'} kcal');
      }
      if (context['todayProtein'] != null) {
        buffer.writeln(
            '- Protein: ${context['todayProtein']}g / ${context['proteinGoal'] ?? '?'}g');
      }
      if (context['recentMeals'] != null) {
        buffer.writeln('- Recent meals: ${context['recentMeals']}');
      }
    }

    return buffer.toString();
  }

  String _formatHistory(List<ChatMessage> history) {
    // Take last N messages (avoid context overflow)
    final recentHistory = history.length > MAX_HISTORY_MESSAGES
        ? history.sublist(history.length - MAX_HISTORY_MESSAGES)
        : history;

    final buffer = StringBuffer();
    for (final msg in recentHistory) {
      if (msg.role == MessageRole.user) {
        buffer.writeln('<|im_start|>user\n${msg.content}<|im_end|>');
      } else if (msg.role == MessageRole.assistant) {
        buffer.writeln('<|im_start|>assistant\n${msg.content}<|im_end|>');
      }
    }

    return buffer.toString();
  }
}
