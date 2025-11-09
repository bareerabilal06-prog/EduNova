import 'dart:math';

class AIServiceOffline {
  // Offline word mapping
  static const Map<String, List<String>> _starterSuggestions = {
    'I': ['am', 'feel', 'need', 'want', 'think', 'like', 'have', 'know', 'understand', 'can', 'will', 'go', 'to', 'washroom'],
    'You': ['are', 'can', 'should', 'will', 'might', 'could', 'would', 'have', 'like', 'need'],
    'We': ['are', 'can', 'will', 'should', 'have', 'like', 'need', 'want', 'think'],
    'He': ['is', 'can', 'will', 'should', 'has', 'likes', 'needs', 'wants'],
    'She': ['is', 'can', 'will', 'should', 'has', 'likes', 'needs', 'wants'],
    'They': ['are', 'can', 'will', 'should', 'have', 'like', 'need', 'want'],
    'Can': ['I', 'you', 'we', 'he', 'she', 'they', 'go', 'help', 'try', 'come'],
    'Will': ['I', 'you', 'we', 'he', 'she', 'they', 'go', 'come', 'help', 'learn'],
    'am': ['happy', 'sad', 'confused', 'tired', 'excited', 'ready', 'curious', 'fine', 'okay'],
    'feel': ['happy', 'sad', 'tired', 'hungry', 'thirsty', 'confused', 'sick', 'great', 'fine'],
    'need': ['help', 'water', 'bathroom', 'break', 'pencil', 'paper', 'explanation', 'rest', 'food'],
    'want': ['to go', 'to', 'to learn', 'to play', 'to eat', 'to rest', 'to read', 'to draw'],
    'think': ['so', 'it’s right', 'it’s wrong', 'we can', 'this is easy', 'this is hard'],
    'like': ['this', 'that', 'school', 'teacher', 'reading', 'drawing', 'music', 'games'],
    'have': ['a pen', 'a book', 'an idea', 'time', 'homework', 'a friend', 'a question'],
    'know': ['the answer', 'this', 'that', 'him', 'her', 'it', 'what to do'],
    'understand': ['this', 'that', 'now', 'the lesson', 'your question'],
    'go': ['to', 'home', 'school', 'washroom', 'class'],
    'to': ['go', 'washroom', 'home', 'school', 'class'],
    'The': ['teacher', 'student', 'class', 'book', 'pen', 'bag', 'lesson', 'board', 'time'],
    'This': ['is', 'book', 'pen', 'paper', 'bag', 'lesson', 'question'],
    'That': ['is', 'book', 'pen', 'bag', 'question', 'idea'],
    'My': ['name', 'book', 'pen', 'friend', 'class', 'teacher', 'idea', 'school'],
    'Your': ['name', 'book', 'pen', 'idea', 'friend', 'class', 'teacher'],
    'Our': ['class', 'teacher', 'project', 'school', 'plan', 'goal'],
    'Their': ['bag', 'books', 'project', 'school', 'friends', 'idea'],
  };

  static const List<String> _rootKeys = [
    'I', 'You', 'We', 'He', 'She', 'They',
    'Can', 'Will', 'The', 'This', 'That',
    'My', 'Your', 'Our', 'Their'
  ];

  /// Returns the first layer of starter words (root keys)
  List<String> getStarterWords() {
    final words = _starterSuggestions.keys
        .where((k) => _rootKeys.contains(k))
        .toList();
    words.shuffle(Random()); // optional randomization
    return words;
  }

  /// Returns suggestions for a given word
  List<String> getSuggestions(String word) {
    if (word.trim().isEmpty) return [];

    final key = _normalizeKey(word);
    if (key == null) return [];

    final suggestions = _starterSuggestions[key] ?? [];
    final shuffled = List<String>.from(suggestions)..shuffle(Random());
    return shuffled;
  }

  /// Normalize user input to match keys
  String? _normalizeKey(String word) {
    if (word.isEmpty) return null;
    if (_starterSuggestions.containsKey(word)) return word;

    final capitalized = word[0].toUpperCase() + word.substring(1).toLowerCase();
    final lower = word.toLowerCase();

    if (_starterSuggestions.containsKey(capitalized)) return capitalized;
    if (_starterSuggestions.containsKey(lower)) return lower;

    return null;
  }
}
