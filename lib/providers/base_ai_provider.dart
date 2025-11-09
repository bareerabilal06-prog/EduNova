import 'package:flutter/foundation.dart';

typedef ErrorCallback = void Function(String message);

abstract class BaseAIProvider extends ChangeNotifier {
  /// The full sentence being built by the user
  String builtSentence = '';

  /// Current word or phrase suggestions
  List<String> currentSuggestions = [];

  /// Loading state
  bool isLoading = false;

  /// Initialize the first batch of suggestions
  Future<void> initSuggestions({ErrorCallback? onError}) async {
    try {
      isLoading = true;
      notifyListeners();

      currentSuggestions = await getAISuggestions('');
    } catch (e) {
      onError?.call('Failed to initialize suggestions: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Add a selected word to the sentence and get next suggestions
  Future<void> addWord(String word, {ErrorCallback? onError}) async {
    try {
      builtSentence = ('${builtSentence.trim()} $word').trim();
      isLoading = true;
      notifyListeners();

      currentSuggestions = await getAISuggestions(builtSentence);
    } catch (e) {
      onError?.call('Failed to add word: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Remove the last word and refresh suggestions
  Future<void> removeLastWord({ErrorCallback? onError}) async {
    try {
      if (builtSentence.isEmpty) return;

      final words = builtSentence.split(' ');
      words.removeLast();
      builtSentence = words.join(' ').trim();

      isLoading = true;
      notifyListeners();

      currentSuggestions = await getAISuggestions(builtSentence);
    } catch (e) {
      onError?.call('Failed to remove word: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Clear the entire sentence and reset suggestions
  Future<void> clearSentence({ErrorCallback? onError}) async {
    try {
      builtSentence = '';
      isLoading = true;
      notifyListeners();

      currentSuggestions = await getAISuggestions('');
    } catch (e) {
      onError?.call('Failed to clear sentence: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✨ Optional: Update suggestions manually (used by UI for refresh or retries)
  void updateSuggestions(List<String> newSuggestions) {
    currentSuggestions = newSuggestions;
    notifyListeners();
  }

  /// Must be implemented by subclasses (offline or online)
  Future<List<String>> getAISuggestions(String partialSentence);
}
