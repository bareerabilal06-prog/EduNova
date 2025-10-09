import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  String _currentLanguage = 'en-US';
  bool _isMaleVoice = true;

  TTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String text, {bool isUrdu = false}) async {
    try {
      String language = isUrdu ? 'ur-PK' : 'en-US';
      await _tts.setLanguage(language);

      // Set voice based on preference
      if (isUrdu) {
        await _tts.setVoice({'name': _isMaleVoice ? 'ur-pk-x-urm-local' : 'ur-pk-x-urf-local', 'locale': 'ur-PK'});
      } else {
        await _tts.setVoice({'name': _isMaleVoice ? 'en-us-x-sfg#male_1-local' : 'en-us-x-sfg#female_1-local', 'locale': 'en-US'});
      }

      await _tts.speak(text);
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void setMaleVoice(bool isMale) {
    _isMaleVoice = isMale;
  }

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _tts.getLanguages;
  }
}