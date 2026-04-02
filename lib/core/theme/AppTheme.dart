// ignore_for_file: file_names

import 'package:flutter/material.dart';

import 'theme_tokens.dart';

class AppTheme {
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: ThemeTokens.primary,
      onPrimary: ThemeTokens.textPrimary,
      secondary: ThemeTokens.success,
      onSecondary: ThemeTokens.background,
      surface: ThemeTokens.surface,
      onSurface: ThemeTokens.textPrimary,
      error: Colors.redAccent,
      onError: ThemeTokens.textPrimary,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: ThemeTokens.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ThemeTokens.background,
      dividerColor: ThemeTokens.border,
      cardTheme: CardThemeData(
        color: ThemeTokens.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: ThemeTokens.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeTokens.surfaceHighlight,
        hintStyle: const TextStyle(color: ThemeTokens.textSecondary),
        labelStyle: const TextStyle(color: ThemeTokens.textSecondary),
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: ThemeTokens.primary, width: 1.2),
        ),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(50),
          backgroundColor: ThemeTokens.primary,
          foregroundColor: ThemeTokens.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          foregroundColor: ThemeTokens.textPrimary,
          side: const BorderSide(color: ThemeTokens.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThemeTokens.surface,
        selectedItemColor: ThemeTokens.primary,
        unselectedItemColor: ThemeTokens.textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ThemeTokens.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
