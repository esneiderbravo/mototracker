import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/motorcycle.dart';
import '../providers/garage_providers.dart';

class AddMotorcycleScreen extends ConsumerStatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  ConsumerState<AddMotorcycleScreen> createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends ConsumerState<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aiQuery = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  final _kmController = TextEditingController();

  XFile? _selectedImage;
  bool _isAiLoading = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _aiQuery.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  Future<void> _autofill() async {
    final t = Translations.of(context);
    if (_aiQuery.text.trim().isEmpty) return;
    setState(() => _isAiLoading = true);

    try {
      final service = ref.read(geminiAiServiceProvider);
      final response = await service.autofillFromPrompt(_aiQuery.text.trim());
      if (response == null) return;

      _makeController.text = response.make;
      _modelController.text = response.model;
      _yearController.text = '${response.year}';
      _colorController.text = response.color;
    } catch (e) {
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.error(context, message: t.garage.aiAutofillError, detail: e);
    } finally {
      if (mounted) setState(() => _isAiLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(imageQuality: 80, source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _selectedImage = image);
  }

  Future<void> _save() async {
    final t = Translations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      if (!mounted) return;
      AppAlerts.error(context, message: t.auth.signInAgain);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repository = ref.read(motorcycleRepositoryProvider);
      String? imageUrl;

      if (_selectedImage != null) {
        final bytes = await _selectedImage!.readAsBytes();
        imageUrl = await repository.uploadImage(
          userId: user.id,
          fileName: _selectedImage!.name,
          bytes: bytes,
        );
      }

      final motorcycle = Motorcycle(
        id: '${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(999)}',
        userId: user.id,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        licensePlate: _plateController.text.trim(),
        currentKm: int.parse(_kmController.text.trim()),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await repository.add(motorcycle);
      if (!mounted) return;
      context.pop();
      AppAlerts.success(context, message: t.garage.saveSuccess);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t.garage.saveError}: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeTokens.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: ThemeTokens.border),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.garage.addMotorcycle,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: ThemeTokens.surfaceHighlight,
                            foregroundColor: ThemeTokens.textPrimary,
                          ),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: ThemeTokens.primary.withOpacity(0.6)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: ThemeTokens.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _aiQuery,
                              decoration: InputDecoration(
                                hintText: "Search with AI: '${t.ai.hintExample}'",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _isAiLoading ? null : _autofill,
                            style: IconButton.styleFrom(
                              backgroundColor: ThemeTokens.primary.withOpacity(0.15),
                              foregroundColor: ThemeTokens.primary,
                            ),
                            icon: _isAiLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.search),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: ThemeTokens.border, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              color: ThemeTokens.textSecondary,
                              size: 44,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _selectedImage == null ? t.garage.addPhoto : _selectedImage!.name,
                              style: const TextStyle(
                                color: ThemeTokens.textSecondary,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _FieldLabel(label: t.garage.make)),
                        const SizedBox(width: 10),
                        Expanded(child: _FieldLabel(label: t.garage.model)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _makeController,
                            validator: (value) =>
                                (value == null || value.isEmpty) ? t.shared.requiredField : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _modelController,
                            validator: (value) =>
                                (value == null || value.isEmpty) ? t.shared.requiredField : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _FieldLabel(label: t.garage.year)),
                        const SizedBox(width: 10),
                        Expanded(child: _FieldLabel(label: t.garage.color)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                (int.tryParse(value ?? '') == null) ? t.shared.invalidNumber : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: TextFormField(controller: _colorController)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _FieldLabel(label: t.garage.licensePlate)),
                        const SizedBox(width: 10),
                        Expanded(child: _FieldLabel(label: t.garage.currentKm)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _plateController)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _kmController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                (int.tryParse(value ?? '') == null) ? t.shared.invalidNumber : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeTokens.primary.withOpacity(0.28),
                            blurRadius: 24,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                t.garage.save,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(label, style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 15)),
    );
  }
}
