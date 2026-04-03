import 'package:flutter/material.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/soat_policy.dart';
import 'soat_status_chip.dart';

class SoatExpiryBanner extends StatelessWidget {
  const SoatExpiryBanner({required this.policy, super.key});

  final SoatPolicy? policy;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    if (policy == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ThemeTokens.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ThemeTokens.border),
        ),
        child: Text(
          t.soat.notFoundByPlate,
          style: const TextStyle(color: ThemeTokens.textSecondary),
        ),
      );
    }

    final status = policy!.expiryStatus(DateTime.now());
    final days = policy!.daysUntilExpiry(DateTime.now());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeTokens.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(policy!.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${days < 0 ? 0 : days} days',
                  style: const TextStyle(color: ThemeTokens.textSecondary),
                ),
              ],
            ),
          ),
          SoatStatusChip(status: status),
        ],
      ),
    );
  }
}
