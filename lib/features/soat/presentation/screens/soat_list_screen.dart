import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/async_value_builder.dart';
import '../providers/soat_providers.dart';
import '../widgets/soat_expiry_banner.dart';
import '../widgets/soat_policy_card.dart';

class SoatListScreen extends ConsumerWidget {
  const SoatListScreen({required this.motorcycleId, super.key});

  final String motorcycleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final policies = ref.watch(soatByMotorcycleProvider(motorcycleId));
    final activePolicy = ref.watch(activeSoatByMotorcycleProvider(motorcycleId));

    return Scaffold(
      appBar: AppBar(title: Text(t.soat.history)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SoatExpiryBanner(policy: activePolicy.valueOrNull),
            const SizedBox(height: 12),
            Expanded(
              child: AsyncValueBuilder(
                value: policies,
                onData: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.soat.empty,
                            style: const TextStyle(color: ThemeTokens.textSecondary),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push('/garage/$motorcycleId/soat/add'),
                            child: Text(t.soat.addPolicy),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final policy = items[index];
                      return SoatPolicyCard(
                        policy: policy,
                        onTap: () => context.push('/garage/$motorcycleId/soat/${policy.id}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/garage/$motorcycleId/soat/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
