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

  /// Load phrases for a specific category AND sync favorite status
  Future<void> loadPhrasesByCategory(int categoryId) async {
    _phrases = await _db.getPhrasesByCategory(categoryId);

    // Update isFavorite based on favorites list
    final favoriteIds = _favorites.map((f) => f.id).toSet();
    _phrases = _phrases
        .map((p) => p.copyWith(isFavorite: favoriteIds.contains(p.id)))
        .toList();

    notifyListeners();
  }

  /// Load favorite phrases AND update phrases list
  Future<void> loadFavorites() async {
    _favorites = await _db.getFavoritePhrases();

    // Update phrases with favorite info
    final favoriteIds = _favorites.map((f) => f.id).toSet();
    _phrases = _phrases
        .map((p) => p.copyWith(isFavorite: favoriteIds.contains(p.id)))
        .toList();

    notifyListeners();
  }

  /// Load category with favorites together (best approach for first load)
  Future<void> loadCategoryWithFavorites(int categoryId) async {
    _favorites = await _db.getFavoritePhrases();
    _phrases = await _db.getPhrasesByCategory(categoryId);

    final favoriteIds = _favorites.map((f) => f.id).toSet();
    _phrases = _phrases
        .map((p) => p.copyWith(isFavorite: favoriteIds.contains(p.id)))
        .toList();

    notifyListeners();
  }

  /// Add new phrase
  Future<void> addPhrase(Phrase phrase) async {
    try {
      await _db.insertPhrase(phrase);
      await loadPhrasesByCategory(phrase.categoryId);
    } catch (e) {
      debugPrint('❌ Error adding phrase: $e');
    }
  }

  Future<void> deletePhrase(int id) async {
    await _db.deletePhrase(id);
    _phrases.removeWhere((p) => p.id == id);
    _favorites.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Check favorite status dynamically
  bool isFavorite(int id) => _favorites.any((p) => p.id == id);

  /// Toggle favorite status
  Future<void> toggleFavorite(Phrase phrase) async {
    final newStatus = !phrase.isFavorite;

    final index = _phrases.indexWhere((p) => p.id == phrase.id);
    if (index != -1) {
      _phrases[index] = _phrases[index].copyWith(isFavorite: newStatus);
    }

    if (newStatus) {
      _favorites.add(phrase.copyWith(isFavorite: true));
    } else {
      _favorites.removeWhere((p) => p.id == phrase.id);
    }

    notifyListeners();
    await _db.toggleFavorite(phrase.id!, newStatus);
  }

  /// Speak phrase
  Future<bool> speakPhrase(Phrase phrase, bool isUrdu) async {
    final text = isUrdu ? phrase.urduText : phrase.englishText;
    debugPrint('📝 speakPhrase called. text="$text", isUrdu=$isUrdu');

    try {
      final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS;

      if (isUrdu && isDesktop) {
        debugPrint('⚠️ Urdu TTS blocked on desktop');
        return false;
      }

      return await _tts.speak(text, isUrdu: isUrdu);
    } catch (e) {
      debugPrint('TTS Error in provider: $e');
      return !isUrdu;
    }
  }

  void setVoiceGender(bool isMale) {
    _tts.setMaleVoice(isMale);
  }
}
