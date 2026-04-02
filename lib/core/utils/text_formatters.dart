import 'package:flutter/services.dart';

/// Converts all typed characters to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  const UpperCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Allows only digits (0-9). Use for numeric-only fields.
class DigitsOnlyFormatter extends TextInputFormatter {
  const DigitsOnlyFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return newValue.copyWith(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Allows alphanumeric characters (a-z, A-Z, 0-9) and spaces. Use for general-purpose text input.
class AlphanumericNoSpaceFormatter extends TextInputFormatter {
  const AlphanumericNoSpaceFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final alphanumericNoSpace = newValue.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return newValue.copyWith(
      text: alphanumericNoSpace,
      selection: TextSelection.collapsed(offset: alphanumericNoSpace.length),
    );
  }
}
