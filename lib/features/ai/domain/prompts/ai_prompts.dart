class AiPrompts {
  const AiPrompts._();

  // Prompt templates live here to keep services free from hardcoded prompt text.
  static const _motorcycleAutofillTemplate = '''
    Extract motorcycle information from the following text:
    "{input}"

    Return ONLY a valid JSON object (no extra text, no explanations) with the exact keys:
    - make (string)
    - model (string)
    - year (number)
    - color (string)

    Rules:
    - Infer values if they are clearly implied.
    - If the color is not mentioned, default to "Black".
    - If make, model, or year cannot be determined, set them to null.
    - Ensure the JSON is strictly valid (double quotes, no trailing commas).

    Example output:
    {
      "make": "Yamaha",
      "model": "MT-07",
      "year": 2022,
      "color": "Black"
    }
  ''';

  static String motorcycleAutofill(String input) {
    return _motorcycleAutofillTemplate.replaceAll('{input}', input);
  }

  static const _motorcycleInsightsTemplate = '''
    You are a motorcycle assistant.
    Output language: {outputLanguage}.

    Given the following motorcycle data:
    - make: {make}
    - model: {model}
    - year: {year}
    - color: {color}
    - current_km: {currentKm}

    Generate practical, concise insights for the owner.

    Return ONLY a valid JSON object with this exact structure:
    {
      "insights": [
        "string",
        "string"
      ]
    }

    Rules:
    - Include 3 to 5 items in the "insights" array.
    - Each item must be a short, actionable sentence (max 120 characters).
    - Focus on maintenance, safety, performance, or resale value.
    - Use the motorcycle data when relevant (e.g., mileage-based maintenance).
    - Do NOT repeat similar ideas.
    - Do NOT include markdown, explanations, or extra keys.
    - Ensure valid JSON (double quotes, no trailing commas).
  ''';

  static String motorcycleInsights({
    required String outputLanguage,
    required String make,
    required String model,
    required int year,
    required String color,
    required int currentKm,
  }) {
    return _motorcycleInsightsTemplate
        .replaceAll('{outputLanguage}', outputLanguage)
        .replaceAll('{make}', make)
        .replaceAll('{model}', model)
        .replaceAll('{year}', '$year')
        .replaceAll('{color}', color)
        .replaceAll('{currentKm}', '$currentKm');
  }
}
