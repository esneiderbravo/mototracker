import '../models/ai_motorcycle_data.dart';

abstract class AiAutofillService {
  Future<AiMotorcycleData?> autofillFromPrompt(String input);
}
