import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isLargeText = false;
  bool _isHighContrast = false;
  bool _isMaleVoice = true;
  String _preferredLanguage = 'en';

  // Optional callback to notify PhraseProvider
  VoidCallback? onVoiceGenderChanged;
  VoidCallback? onLanguageChanged;

  bool get isLargeText => _isLargeText;
  bool get isHighContrast => _isHighContrast;
  bool get isMaleVoice => _isMaleVoice;
  String get preferredLanguage => _preferredLanguage;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isLargeText = prefs.getBool('largeText') ?? false;
    _isHighContrast = prefs.getBool('highContrast') ?? false;
    _isMaleVoice = prefs.getBool('maleVoice') ?? true;
    _preferredLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> toggleLargeText() async {
    _isLargeText = !_isLargeText;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('largeText', _isLargeText);
    notifyListeners();
  }

  Future<void> toggleHighContrast() async {
    _isHighContrast = !_isHighContrast;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', _isHighContrast);
    notifyListeners();
  }

  Future<void> toggleVoiceGender() async {
    _isMaleVoice = !_isMaleVoice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('maleVoice', _isMaleVoice);
    notifyListeners();

    // Notify PhraseProvider immediately
    if (onVoiceGenderChanged != null) {
      onVoiceGenderChanged!();
    }
  }

  Future<void> setLanguage(String lang) async {
    _preferredLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();

    // Notify PhraseProvider immediately
    if (onLanguageChanged != null) {
      onLanguageChanged!();
    }
  }
}
