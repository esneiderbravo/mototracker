import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/env.dart';
import '../../domain/services/ai_autofill_service.dart';
import '../../data/fallback_ai_autofill_service.dart';
import '../../data/gemini_ai_service.dart';
import '../../data/groq_ai_service.dart';

final geminiAiServiceProvider = Provider<GeminiAiService>((ref) {
  return GeminiAiService();
});

final groqAiServiceProvider = Provider<GroqAiService>((ref) {
  return GroqAiService();
});

final aiAutofillServiceProvider = Provider<AiAutofillService>((ref) {
  final gemini = ref.watch(geminiAiServiceProvider);
  final primary = switch (Env.aiPrimaryProvider.toLowerCase()) {
    'gemini' => gemini,
    'groq' => ref.watch(groqAiServiceProvider),
    _ => ref.watch(groqAiServiceProvider),
  };

  if (identical(primary, gemini)) return gemini;
  return FallbackAiAutofillService(primary: primary, fallback: gemini);
});

