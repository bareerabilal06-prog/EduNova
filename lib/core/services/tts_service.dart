import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  bool _isMaleVoice = true;

  TTSService() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  void setMaleVoice(bool isMale) {
    _isMaleVoice = isMale;
  }

  /// Speak text. Returns false if Urdu is not available on desktop
  Future<bool> speak(String text, {bool isUrdu = false}) async {
    debugPrint('🔊 TTSService.speak called. text="$text", isUrdu=$isUrdu');
    try {
      if (text.trim().isEmpty) return true;

      if (isUrdu) {
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          debugPrint('⚠️ Urdu TTS not supported on desktop');
          return false;
        }
        await _tts.setLanguage('ur-PK');
        await _tts.speak(text);
        return true;
      }

      await _tts.setLanguage('en-US');
      await _setEnglishVoice();

      await _tts.speak(text);
      return true;
    } catch (e) {
      debugPrint('TTS Error: $e');
      return !isUrdu;
    }
  }

  /// Dynamically set English voice based on _isMaleVoice, with desktop fallback
  Future<void> _setEnglishVoice() async {
    try {
      final voices = await _tts.getVoices;
      debugPrint('Available voices: $voices');

      if (voices == null || voices.isEmpty) return;

      Map<String, dynamic> rawVoice;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop fallback: pick first English voice
        rawVoice = voices.firstWhere(
              (v) => (v['locale']?.toString().toLowerCase() ?? '').startsWith('en'),
          orElse: () => voices.first,
        );
      } else {
        // Mobile: try to pick male/female voice
        rawVoice = voices.firstWhere(
              (v) {
            final name = v['name']?.toString().toLowerCase() ?? '';
            final locale = v['locale']?.toString().toLowerCase() ?? '';
            final isEnglish = locale.startsWith('en');
            if (!isEnglish) return false;
            return _isMaleVoice ? name.contains('male') : name.contains('female');
          },
          orElse: () {
            // fallback to first English voice if preferred not found
            return voices.firstWhere(
                  (v) => (v['locale']?.toString().toLowerCase() ?? '').startsWith('en'),
              orElse: () => voices.first,
            );
          },
        );
      }

      // Convert Map<String, dynamic> to Map<String, String>
      final voice = rawVoice.map((key, value) => MapEntry(key, value.toString()));

      await _tts.setVoice(voice);
      debugPrint('Selected voice: $voice');
    } catch (e) {
      debugPrint('Error selecting voice: $e');
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
