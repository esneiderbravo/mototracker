import 'package:flutter/material.dart';

import '../../core/theme/theme_tokens.dart';
import '../../i18n/strings.g.dart';

/// Centralized alert helper for MotoTracker.
///
/// Shows a top-positioned floating toast below the Dynamic Island / notch.
/// Always call these from a mounted context.
///
/// Usage:
/// ```dart
/// AppAlerts.success(context, message: t.profile.saveSuccess);
/// AppAlerts.error(context, message: t.profile.saveError);
/// ```
class AppAlerts {
  const AppAlerts._();

  static OverlayEntry? _current;

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

  static void error(BuildContext context, {required String message, Object? detail}) {
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

    // Dismiss any existing toast before showing a new one.
    _dismiss();

    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).viewPadding.top;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopToast(
        message: message,
        icon: icon,
        backgroundColor: backgroundColor,
        textColor: textColor,
        topOffset: topPadding + 8,
        onDismiss: () => _dismiss(),
      ),
    );

    _current = entry;
    overlay.insert(entry);

    // Auto-dismiss after 3 seconds.
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  static void _dismiss() {
    _current?.remove();
    _current = null;
  }

  /// Strips raw Supabase/SDK details for users and returns a single line.
  static String _friendlyDetail(Object err) {
    final raw = err.toString();
    final firstLine = raw.split('\n').first.trim();
    return firstLine.length > 120 ? '${firstLine.substring(0, 120)}…' : firstLine;
  }
}

class _TopToast extends StatefulWidget {
  const _TopToast({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.topOffset,
    required this.onDismiss,
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final double topOffset;
  final VoidCallback onDismiss;

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topOffset,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.textColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
