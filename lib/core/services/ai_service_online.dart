import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIServiceOnline {
  static const String _baseUrl = "https://openrouter.ai/api/v1/chat/completions";

  /// ✅ Starter words for initializing UI
  List<String> getStarterWords() {
    return [
      "I",
      "You",
      "We",
      "They",
      "He",
      "She",
      "It",
      "This",
      "That",
      "My",
      "Your",
    ];
  }

  /// 🧠 Fetch suggestions from OpenRouter
  Future<List<String>> getAISuggestions(
      String prompt, {
        required String apiKey,
        String model = "gpt-4o-mini", // ✅ modern default
      }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": model,
          "messages": [
            {
              "role": "system",
              "content":
              "You are a predictive language assistant. Based on the user’s partial sentence, "
                  "suggest 5 likely next words or short phrases. "
                  "Return only the suggestions as a JSON array of strings. "
                  "No explanations or extra text."
            },
            {
              "role": "user",
              "content": "Sentence: $prompt"
            }
          ],
          "max_tokens": 50,
          "temperature": 0.7,
        }),
      )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String content = data["choices"]?[0]?["message"]?["content"] ?? "";

        // 🧹 Clean markdown wrappers if present (e.g. ```json ... ```)
        content = content.replaceAll(RegExp(r'```(json)?'), '').trim();

        // Try parsing JSON array directly
        final parsed = jsonDecode(content);
        if (parsed is List) {
          return parsed.map((e) => e.toString().trim()).toList();
        } else {
          debugPrint("⚠️ Unexpected format from API: $content");
        }
      } else {
        debugPrint(
            "❌ OpenRouter API error: ${response.statusCode} → ${response.body}");
      }
    } on TimeoutException {
      debugPrint("⏱️ OpenRouter request timed out.");
    } catch (e) {
      debugPrint("❌ Exception in getAISuggestions: $e");
    }

    // 🚫 No fallback — return empty list on failure
    return [];
  }
}
