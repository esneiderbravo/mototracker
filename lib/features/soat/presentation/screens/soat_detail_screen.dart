import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../../../../shared/widgets/async_value_builder.dart';
import '../../domain/entities/soat_policy.dart';
import '../providers/soat_providers.dart';
import '../widgets/soat_status_chip.dart';

class SoatDetailScreen extends ConsumerWidget {
  const SoatDetailScreen({required this.motorcycleId, required this.soatId, super.key});

  final String motorcycleId;
  final String soatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final asyncPolicy = ref.watch(soatByIdProvider(soatId));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.soat.title),
        actions: [
          IconButton(
            onPressed: () => _delete(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: AsyncValueBuilder(
        value: asyncPolicy,
        onData: (policy) {
          if (policy == null) {
            return Center(child: Text(t.soat.notFoundByPlate));
          }

          final locale = Localizations.localeOf(context).toString();
          final start = DateFormat.yMMMMd(locale).format(policy.startDate);
          final end = DateFormat.yMMMMd(locale).format(policy.expiryDate);
          final days = policy.daysUntilExpiry(DateTime.now());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(policy.policyNumber, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(policy.insurer),
              const SizedBox(height: 8),
              SoatStatusChip(status: policy.expiryStatus(DateTime.now())),
              const SizedBox(height: 20),
              Text('${t.soat.startDate}: $start'),
              const SizedBox(height: 8),
              Text('${t.soat.expiryDate}: $end'),
              const SizedBox(height: 8),
              Text('${t.soat.daysUntilExpiry}: $days'),
              const SizedBox(height: 16),
              Text(policy.notes),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => _openEditDialog(context, ref, policy),
                icon: const Icon(Icons.edit_outlined),
                label: Text(t.shared.edit),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final t = Translations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.garage.delete),
        content: Text(t.soat.deleteConfirmation),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.shared.cancel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t.garage.delete)),
        ],
      ),
    );

    if (shouldDelete != true) return;
    try {
      await ref.read(soatPolicyRepositoryProvider).remove(soatId);
      ref
        ..invalidate(soatByMotorcycleProvider(motorcycleId))
        ..invalidate(activeSoatByMotorcycleProvider(motorcycleId));
      if (context.mounted) {
        context.pop();
      }
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, message: t.soat.saveError, detail: error);
      }
    }
  }

  Future<void> _openEditDialog(BuildContext context, WidgetRef ref, SoatPolicy policy) async {
    final t = Translations.of(context);
    final insurerController = TextEditingController(text: policy.insurer);
    final notesController = TextEditingController(text: policy.notes);

    final updated = await showDialog<SoatPolicy>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.shared.edit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: insurerController,
                decoration: InputDecoration(labelText: t.soat.insurer),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: t.soat.notes),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.shared.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  policy.copyWith(
                    insurer: insurerController.text.trim(),
                    notes: notesController.text.trim(),
                  ),
                );
              },
              child: Text(t.shared.save),
            ),
          ],
        );
      },
    );

    insurerController.dispose();
    notesController.dispose();

    if (updated == null) return;

    try {
      await ref.read(soatPolicyRepositoryProvider).update(updated);
      ref
        ..invalidate(soatByIdProvider(soatId))
        ..invalidate(soatByMotorcycleProvider(motorcycleId))
        ..invalidate(activeSoatByMotorcycleProvider(motorcycleId));
      if (context.mounted) {
        AppAlerts.success(context, message: t.soat.saveSuccess);
      }
    } catch (error) {
      if (context.mounted) {
        AppAlerts.error(context, message: t.soat.saveError, detail: error);
      }
    }
  }
}
