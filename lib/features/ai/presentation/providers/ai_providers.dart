import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/ai_autofill_service.dart';
import '../../data/groq_ai_service.dart';

final groqAiServiceProvider = Provider<GroqAiService>((ref) {
  return GroqAiService();
});

final aiAutofillServiceProvider = Provider<AiAutofillService>((ref) {
  return ref.watch(groqAiServiceProvider);
});
