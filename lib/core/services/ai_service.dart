import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // AI Sentence Builder mapping
  static const Map<String, List<String>> starterSuggestions = {
    'I': ['am', 'feel', 'need', 'want', 'think', 'like', 'have', 'know', 'understand'],
    'You': ['are', 'can', 'should', 'will', 'might', 'could'],
    'We': ['are', 'can', 'should', 'will'],
    'He': ['is', 'can', 'will', 'should'],
    'She': ['is', 'can', 'will', 'should'],
    'They': ['are', 'can', 'will', 'should'],
    'Can': ['I', 'you', 'we', 'they', 'he', 'she'],
    'Will': ['I', 'you', 'we', 'they', 'he', 'she'],
    'am': ['happy', 'sad', 'tired', 'excited', 'ready', 'confused', 'fine'],
    'feel': ['good', 'bad', 'sick', 'better', 'hungry', 'thirsty'],
    'need': ['help', 'water', 'break', 'teacher', 'bathroom', 'time'],
  };

  List<String> getSuggestions(String currentWord) {
    return starterSuggestions[currentWord] ?? [];
  }

  List<String> getStarterWords() {
    return ['I', 'You', 'We', 'He', 'She', 'They', 'Can', 'Will', 'The', 'This', 'That', 'My', 'Your', 'Our', 'Their'];
  }

  // Optional: OpenAI integration for advanced suggestions
  Future<String?> getAISuggestion(String partialSentence) async {
    // Implement OpenAI API call here if needed
    // This is a placeholder for online AI functionality
    return null;
  }
}