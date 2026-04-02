import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/env.dart';
import '../domain/prompts/ai_prompts.dart';
import '../domain/models/ai_motorcycle_data.dart';
import '../domain/services/ai_autofill_service.dart';

class GeminiAiService implements AiAutofillService {
  GeminiAiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<AiMotorcycleData?> autofillFromPrompt(String input) async {
    const apiKey = Env.geminiApiKey;
    if (apiKey.isEmpty) {
      return _fallbackParse(input);
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final prompt = AiPrompts.motorcycleAutofill(input);

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    });

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode >= 400) {
      return _fallbackParse(input);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = body['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (content == null || content.isEmpty) {
      return _fallbackParse(input);
    }

    final jsonText = _extractJson(content);
    if (jsonText == null) {
      return _fallbackParse(input);
    }

    return AiMotorcycleData.fromJson(jsonDecode(jsonText) as Map<String, dynamic>);
  }

  String? _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    return raw.substring(start, end + 1);
  }

  AiMotorcycleData _fallbackParse(String input) {
    final parts = input.split(' ').where((e) => e.trim().isNotEmpty).toList();
    final year = parts
        .map((p) => int.tryParse(p))
        .whereType<int>()
        .firstWhere(
          (y) => y > 1950 && y <= DateTime.now().year + 1,
          orElse: () => DateTime.now().year,
        );

    final make = parts.isNotEmpty ? parts.first : 'Unknown';
    final model = parts.length > 1 ? parts[1] : 'Model';

    return AiMotorcycleData(make: make, model: model, year: year, color: 'Black');
  }
}
