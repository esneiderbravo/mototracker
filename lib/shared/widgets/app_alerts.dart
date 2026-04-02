import 'package:flutter/material.dart';

import '../../core/theme/theme_tokens.dart';
import '../../i18n/strings.g.dart';

/// Centralized alert helper for MotoTracker.
///
/// Provides consistent success and error feedback as themed SnackBars.
/// Always call these from a mounted context.
///
/// Usage:
/// ```dart
/// AppAlerts.success(context, message: t.profile.saveSuccess);
/// AppAlerts.error(context, message: t.profile.saveError);
/// ```
class AppAlerts {
  const AppAlerts._();

  // ── Success ──────────────────────────────────────────────────────────────

  static void success(BuildContext context, {required String message}) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: ThemeTokens.success,
      textColor: Colors.black87,
    );
  }

  // ── Error ─────────────────────────────────────────────────────────────────

  static void error(
    BuildContext context, {
    required String message,
    Object? detail,
  }) {
    final displayMessage = detail != null ? '$message\n${_friendlyDetail(detail)}' : message;
    _show(
      context,
      message: displayMessage,
      icon: Icons.error_outline_rounded,
      backgroundColor: const Color(0xFFB71C1C),
      textColor: Colors.white,
    );
  }

  /// Shows a generic "unexpected error" message using the shared translation key.
  static void unexpected(BuildContext context) {
    final t = Translations.of(context);
    error(context, message: t.shared.unknownError);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: textColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Strips raw Supabase/SDK details for users and returns a single line.
  static String _friendlyDetail(Object err) {
    final raw = err.toString();
    // Show only the first sentence to avoid leaking stack traces.
    final firstLine = raw.split('\n').first.trim();
    return firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
  }
}

