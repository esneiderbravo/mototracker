import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/env.dart';
import '../domain/models/ai_motorcycle_data.dart';
import '../domain/prompts/ai_prompts.dart';
import '../domain/services/ai_autofill_service.dart';

class GroqAiService implements AiAutofillService {
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

  String? _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    return raw.substring(start, end + 1);
  }
}
