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
}
