class AiPrompts {
  const AiPrompts._();

  // Prompt templates live here to keep services free from hardcoded prompt text.
  static const _motorcycleAutofillTemplate = '''
    Extract motorcycle information from this text: "{input}"
    Return strictly valid JSON with keys: make, model, year, color.
    If unknown color use "Black".
  ''';

  static String motorcycleAutofill(String input) {
    return _motorcycleAutofillTemplate.replaceAll('{input}', input);
  }
}
