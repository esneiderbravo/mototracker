import '../domain/models/ai_motorcycle_data.dart';
import '../domain/services/ai_autofill_service.dart';

class FallbackAiAutofillService implements AiAutofillService {
  FallbackAiAutofillService({required this.primary, required this.fallback});

  final AiAutofillService primary;
  final AiAutofillService fallback;

  @override
  Future<AiMotorcycleData?> autofillFromPrompt(String input) async {
    try {
      final primaryResult = await primary.autofillFromPrompt(input);
      if (_isUsable(primaryResult)) return primaryResult;
    } catch (_) {
      // Ignore and continue with fallback provider.
    }

    return fallback.autofillFromPrompt(input);
  }

  bool _isUsable(AiMotorcycleData? data) {
    if (data == null) return false;
    if (data.make.trim().isEmpty || data.model.trim().isEmpty) return false;
    return data.year > 1950 && data.year <= DateTime.now().year + 1;
  }
}
