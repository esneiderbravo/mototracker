import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/soat_policy.dart';

class SoatStatusChip extends StatelessWidget {
  const SoatStatusChip({required this.status, super.key});

  final SoatExpiryStatus status;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _backgroundFor(status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _labelFor(t, status),
        style: const TextStyle(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _labelFor(Translations t, SoatExpiryStatus value) {
    switch (value) {
      case SoatExpiryStatus.active:
        return t.soat.statuses.active;
      case SoatExpiryStatus.due30:
        return t.soat.statuses.due30;
      case SoatExpiryStatus.due15:
        return t.soat.statuses.due15;
      case SoatExpiryStatus.due5:
        return t.soat.statuses.due5;
      case SoatExpiryStatus.expired:
        return t.soat.statuses.expired;
    }
  }

  Color _backgroundFor(SoatExpiryStatus value) {
    switch (value) {
      case SoatExpiryStatus.active:
        return ThemeTokens.success.withValues(alpha: 0.45);
      case SoatExpiryStatus.due30:
        return ThemeTokens.primary.withValues(alpha: 0.35);
      case SoatExpiryStatus.due15:
        return ThemeTokens.primaryDark.withValues(alpha: 0.55);
      case SoatExpiryStatus.due5:
        return const Color(0xFFEF6C00);
      case SoatExpiryStatus.expired:
        return const Color(0xFFB71C1C);
    }
  }
}
