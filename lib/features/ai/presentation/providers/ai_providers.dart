import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/ai_service.dart';
import '../../data/groq_ai_service.dart';

final groqAiServiceProvider = Provider<GroqAiService>((ref) {
  return GroqAiService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return ref.watch(groqAiServiceProvider);
});

typedef AiInsightsInput = ({
  String languageCode,
  String make,
  String model,
  int year,
  String color,
  int currentKm,
});

final aiInsightsProvider = FutureProvider.family<List<String>, AiInsightsInput>((ref, input) async {
  final service = ref.watch(aiServiceProvider);
  return service.generateMotorcycleInsights(
    languageCode: input.languageCode,
    make: input.make,
    model: input.model,
    year: input.year,
    color: input.color,
    currentKm: input.currentKm,
  );
});
