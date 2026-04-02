import '../models/ai_motorcycle_data.dart';

abstract class AiService {
  Future<AiMotorcycleData?> autofillFromPrompt(String input);

  Future<List<String>> generateMotorcycleInsights({
    required String languageCode,
    required String make,
    required String model,
    required int year,
    required String color,
    required int currentKm,
  });
}
