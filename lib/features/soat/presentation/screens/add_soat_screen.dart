import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/soat_policy.dart';
import '../providers/soat_providers.dart';

final _soatSavingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AddSoatScreen extends ConsumerStatefulWidget {
  const AddSoatScreen({required this.motorcycleId, super.key});

  final String motorcycleId;

  @override
  ConsumerState<AddSoatScreen> createState() => _AddSoatScreenState();
}

class _AddSoatScreenState extends ConsumerState<AddSoatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _insurerController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _insurerController.dispose();
    _policyNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _startDate ?? DateTime.now(),
    );
    if (selected == null) return;
    _startDate = selected;
    if (mounted) {
      ref.invalidate(_soatSavingProvider);
      setState(() {});
    }
  }

  Future<void> _pickExpiryDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (selected == null) return;
    _expiryDate = selected;
    if (mounted) {
      ref.invalidate(_soatSavingProvider);
      setState(() {});
    }
  }

  Future<void> _save() async {
    final t = Translations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _expiryDate == null) {
      AppAlerts.error(context, message: t.shared.requiredField);
      return;
    }
    if (!_expiryDate!.isAfter(_startDate!)) {
      AppAlerts.error(context, message: t.soat.invalidDateRange);
      return;
    }

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      AppAlerts.error(context, message: t.auth.signInAgain);
      return;
    }

    ref.read(_soatSavingProvider.notifier).state = true;
    try {
      final policy = SoatPolicy(
        id: '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}',
        userId: user.id,
        motorcycleId: widget.motorcycleId,
        insurer: _insurerController.text.trim(),
        policyNumber: _policyNumberController.text.trim().toUpperCase(),
        startDate: _startDate!,
        expiryDate: _expiryDate!,
        notes: _notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(soatPolicyRepositoryProvider).add(policy);
      ref
        ..invalidate(soatByMotorcycleProvider(widget.motorcycleId))
        ..invalidate(activeSoatByMotorcycleProvider(widget.motorcycleId));

      if (!mounted) return;
      context.pop();
      AppAlerts.success(context, message: t.soat.saveSuccess);
    } catch (error) {
      if (!mounted) return;
      AppAlerts.error(context, message: t.soat.saveError, detail: error);
    } finally {
      ref.read(_soatSavingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final isSaving = ref.watch(_soatSavingProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.soat.addPolicy)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _insurerController,
                decoration: InputDecoration(labelText: t.soat.insurer),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? t.shared.requiredField : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _policyNumberController,
                decoration: InputDecoration(labelText: t.soat.policyNumber),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? t.shared.requiredField : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(t.soat.startDate),
                subtitle: Text(_startDate?.toIso8601String().split('T').first ?? '-'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickStartDate,
              ),
              ListTile(
                title: Text(t.soat.expiryDate),
                subtitle: Text(_expiryDate?.toIso8601String().split('T').first ?? '-'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickExpiryDate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(labelText: t.soat.notes),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : _save,
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(t.garage.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
