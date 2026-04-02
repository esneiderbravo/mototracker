import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/env.dart';
import '../domain/models/ai_motorcycle_data.dart';
import '../domain/prompts/ai_prompts.dart';
import '../domain/services/ai_service.dart';

class GroqAiService implements AiService {
  GroqAiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AiMotorcycleData?> autofillFromPrompt(String input) async {
    final apiKey = Env.groqApiKey;
    if (apiKey.isEmpty) return null;

    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final prompt = AiPrompts.motorcycleAutofill(input);

    final requestBody = jsonEncode({
      'model': Env.groqModel,
      'temperature': 0.2,
      'messages': [
        {'role': 'user', 'content': prompt},
      ],
    });

    final response = await _client.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode >= 400) return null;

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) return null;

    final jsonText = _extractJson(content);
    if (jsonText == null) return null;

    return AiMotorcycleData.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);
  }

  @override
  Future<List<String>> generateMotorcycleInsights({
    required String languageCode,
    required String make,
    required String model,
    required int year,
    required String color,
    required int currentKm,
  }) async {
    final apiKey = Env.groqApiKey;
    if (apiKey.isEmpty) return const [];
    final outputLanguage = _normalizeOutputLanguage(languageCode);

    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final prompt = AiPrompts.motorcycleInsights(
      outputLanguage: outputLanguage,
      make: make,
      model: model,
      year: year,
      color: color,
      currentKm: currentKm,
    );

    final requestBody = jsonEncode({
      'model': Env.groqModel,
      'temperature': 0.4,
      'messages': [
        {
          'role': 'system',
          'content':
              'You generate concise motorcycle insights and always reply with strict JSON only in $outputLanguage.',
        },
        {'role': 'user', 'content': prompt},
      ],
    });

    final response = await _client.post(
      uri,
      headers: {'Authorization': 'Bearer $apiKey', 'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode >= 400) return const [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = body['choices']?[0]?['message']?['content'] as String?;
    if (content == null || content.trim().isEmpty) return const [];

    final jsonText = _extractJson(content);
    if (jsonText == null) return const [];

    try {
      final map = jsonDecode(jsonText) as Map<String, dynamic>;
      final rawInsights = map['insights'] as List<dynamic>?;
      if (rawInsights == null) return const [];
      return rawInsights
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .take(5)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  String? _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    return raw.substring(start, end + 1);
  }

  String _normalizeOutputLanguage(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'es':
        return 'Spanish';
      case 'en':
        return 'English';
      default:
        // Fallback to English for unsupported locales.
        return 'English';
    }
  }
}
