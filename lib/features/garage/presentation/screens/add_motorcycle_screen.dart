import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/env.dart';
import '../../../../core/theme/theme_tokens.dart';
import '../../../../core/utils/text_formatters.dart';
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
    final query = _aiQuery.text.trim();
    if (query.isEmpty) return;
    if (Env.groqApiKey.isEmpty) {
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.error(
        context,
        message: t.ai.error,
        detail: 'Missing GROQ_API_KEY. Run with --dart-define-from-file=config/env.json.',
      );
      return;
    }

    setState(() => _isAiLoading = true);

    try {
      final service = ref.read(aiServiceProvider);
      final response = await service.autofillFromPrompt(query);
      if (response == null) {
        if (!mounted) return;
        final t = Translations.of(context);
        AppAlerts.error(context, message: t.ai.error, detail: 'AI provider returned no data.');
        return;
      }

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
      ref.invalidate(motorcyclesProvider);
      if (!mounted) return;
      context.pop();
      AppAlerts.success(context, message: t.garage.saveSuccess);
    } catch (e) {
      if (!mounted) return;
      AppAlerts.error(context, message: t.garage.saveError, detail: e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      backgroundColor: ThemeTokens.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ThemeTokens.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: ThemeTokens.border),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
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
                          const SizedBox(height: 6),
                          Text(
                            'Use AI to start fast, then fine-tune details.',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: ThemeTokens.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          _SectionCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _aiQuery,
                                    textInputAction: TextInputAction.search,
                                    onSubmitted: (_) => _autofill(),
                                    decoration: InputDecoration(
                                      hintText: "${t.ai.searchWithAi}: '${t.ai.hintExample}'",
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _isAiLoading ? null : _autofill,
                                  style: IconButton.styleFrom(
                                    backgroundColor: ThemeTokens.primary.withOpacity(0.18),
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
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 170,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: ThemeTokens.border),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF141414), Color(0xFF0E0E0E)],
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    color: ThemeTokens.textSecondary,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedImage == null
                                        ? t.garage.addPhoto
                                        : _selectedImage!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: ThemeTokens.textSecondary,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.make,
                                  controller: _makeController,
                                  validator: (value) => (value == null || value.isEmpty)
                                      ? t.shared.requiredField
                                      : null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.model,
                                  controller: _modelController,
                                  validator: (value) => (value == null || value.isEmpty)
                                      ? t.shared.requiredField
                                      : null,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.year,
                                  controller: _yearController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => (int.tryParse(value ?? '') == null)
                                      ? t.shared.invalidNumber
                                      : null,
                                  inputFormatters: [const DigitsOnlyFormatter()],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.color,
                                  controller: _colorController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.licensePlate,
                                  controller: _plateController,
                                  textCapitalization: TextCapitalization.characters,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                    const UpperCaseTextFormatter(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ModernTextField(
                                  label: t.garage.currentKm,
                                  controller: _kmController,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => (int.tryParse(value ?? '') == null)
                                      ? t.shared.invalidNumber
                                      : null,
                                  inputFormatters: [const DigitsOnlyFormatter()],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 58)),
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeTokens.surfaceHighlight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeTokens.primary.withOpacity(0.45)),
      ),
      child: child,
    );
  }
}

class _ModernTextField extends StatelessWidget {
  const _ModernTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              color: ThemeTokens.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          style: const TextStyle(color: ThemeTokens.textPrimary, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: ThemeTokens.surfaceHighlight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ThemeTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: ThemeTokens.primary, width: 1.2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
