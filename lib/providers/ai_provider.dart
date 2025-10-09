import 'package:flutter/foundation.dart';
import '../core/services/ai_service.dart';

class AIProvider with ChangeNotifier {
  final AIService _aiService = AIService();
  List<String> _currentSuggestions = [];
  String _builtSentence = '';

  List<String> get currentSuggestions => _currentSuggestions;
  String get builtSentence => _builtSentence;

  List<String> getStarterWords() {
    return _aiService.getStarterWords();
  }

  void addWord(String word) {
    if (_builtSentence.isEmpty) {
      _builtSentence = word;
    } else {
      _builtSentence += ' $word';
    }
    _currentSuggestions = _aiService.getSuggestions(word);
    notifyListeners();
  }

  void clearSentence() {
    _builtSentence = '';
    _currentSuggestions = [];
    notifyListeners();
  }

  void removeLastWord() {
    List<String> words = _builtSentence.split(' ');
    if (words.isNotEmpty) {
      words.removeLast();
      _builtSentence = words.join(' ');
      notifyListeners();
    }
  }
}