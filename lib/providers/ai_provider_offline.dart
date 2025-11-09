import 'dart:async';
import '../core/services/ai_service_offline.dart';
import 'base_ai_provider.dart';

class AIProviderOffline extends BaseAIProvider {
  final AIServiceOffline _aiService = AIServiceOffline();

  AIProviderOffline() {
    // Initialize with starter words
    currentSuggestions = _aiService.getStarterWords();
  }

  /// 🔹 Implementation required by BaseAIProvider
  @override
  Future<List<String>> getAISuggestions(String partialSentence) async {
    final trimmed = partialSentence.trim();

    // Return starter words if empty
    if (trimmed.isEmpty) {
      return _aiService.getStarterWords();
    }

    // Simulate a tiny delay for smooth UX
    await Future.delayed(const Duration(milliseconds: 300));

    // Get last word
    final words = trimmed.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return _aiService.getStarterWords();

    final lastWord = words.last;

    // Return suggestions for the last word
    return _aiService.getSuggestions(lastWord);
  }
}
