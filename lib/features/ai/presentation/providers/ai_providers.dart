import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/gemini_ai_service.dart';

final geminiAiServiceProvider = Provider<GeminiAiService>((ref) {
  return GeminiAiService();
});
