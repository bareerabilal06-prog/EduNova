import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/services/ai_service_online.dart';
import 'base_ai_provider.dart';

class AIProviderOnline extends BaseAIProvider {
  final AIServiceOnline _aiService = AIServiceOnline();

  // ✅ Load key from environment (with a safety warning)
  late final String apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  AIProviderOnline() {
    currentSuggestions = _aiService.getStarterWords();

    // Warn if API key missing
    if (apiKey.isEmpty && kDebugMode) {
      if (kDebugMode) {
        print('⚠️ Warning: OPENROUTER_API_KEY is missing in .env file.');
      }
    }
  }

  /// ✅ Checks internet connectivity before making API calls
  Future<bool> _isInternetAvailable() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// 🧠 Fetch AI-generated suggestions via OpenRouter
  @override
  Future<List<String>> getAISuggestions(String partialSentence) async {
    if (partialSentence.trim().isEmpty) {
      return _aiService.getStarterWords();
    }

    // Check connectivity
    final hasInternet = await _isInternetAvailable();
    if (!hasInternet) {
      if (kDebugMode) print('❌ No internet connection.');
      return [];
    }

    // Ensure API key is available
    if (apiKey.isEmpty) {
      if (kDebugMode) print('❌ Missing API key.');
      return [];
    }

    try {
      final suggestions =
      await _aiService.getAISuggestions(partialSentence, apiKey: apiKey);

      if (suggestions.isEmpty && kDebugMode) {
        if (kDebugMode) {
          print('⚠️ OpenRouter returned no suggestions.');
        }
      }

      return suggestions;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching AI suggestions: $e');
      }
      return [];
    }
  }
}
