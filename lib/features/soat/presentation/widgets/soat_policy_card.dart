import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../domain/entities/soat_policy.dart';
import 'soat_status_chip.dart';

class SoatPolicyCard extends StatelessWidget {
  const SoatPolicyCard({required this.policy, required this.onTap, super.key});

  final SoatPolicy policy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final expiry = DateFormat.yMMMd(locale).format(policy.expiryDate);
    final status = policy.expiryStatus(DateTime.now());

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      policy.policyNumber,
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  SoatStatusChip(status: status),
                ],
              ),
              const SizedBox(height: 8),
              Text(policy.insurer, style: const TextStyle(color: ThemeTokens.textSecondary)),
              const SizedBox(height: 8),
              Text('Expiry: $expiry'),
            ],
          ),
        ),
      ),
    );
  }
}
