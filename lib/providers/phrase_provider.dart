import 'package:flutter/foundation.dart';
import '../core/models/phrase.dart';
import '../core/services/database_service.dart';
import '../core/services/tts_service.dart';

class PhraseProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final TTSService _tts = TTSService();
  List<Phrase> _phrases = [];
  List<Phrase> _favorites = [];

  List<Phrase> get phrases => _phrases;
  List<Phrase> get favorites => _favorites;

  Future<void> loadPhrasesByCategory(int categoryId) async {
    _phrases = await _db.getPhrasesByCategory(categoryId);
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _favorites = await _db.getFavoritePhrases();
    notifyListeners();
  }

  Future<void> toggleFavorite(Phrase phrase) async {
    await _db.toggleFavorite(phrase.id!, !phrase.isFavorite);
    await loadFavorites();
    notifyListeners();
  }

  Future<void> speakPhrase(Phrase phrase, bool isUrdu) async {
    String text = isUrdu ? phrase.urduText : phrase.englishText;
    await _tts.speak(text, isUrdu: isUrdu);
  }

  void setVoiceGender(bool isMale) {
    _tts.setMaleVoice(isMale);
  }
}