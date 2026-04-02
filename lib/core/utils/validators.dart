class Validators {
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required field';
    }
    return null;
  }

  static String? numeric(String? value) {
    if (int.tryParse(value ?? '') == null) {
      return 'Invalid number';
    }
    return null;
  }
}
