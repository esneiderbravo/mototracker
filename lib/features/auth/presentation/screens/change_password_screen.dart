import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../providers/auth_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final t = Translations.of(context);
    try {
      await ref.read(authRepositoryProvider).changePassword(newPassword: _newController.text);
      if (!mounted) return;
      AppAlerts.success(context, message: t.auth.passwordChanged);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.error(context, message: t.auth.passwordChangeError, detail: e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Container(
            decoration: BoxDecoration(
              color: ThemeTokens.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: ThemeTokens.border),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── header ────────────────────────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: ThemeTokens.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.lock_outline, color: ThemeTokens.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            t.auth.changePasswordTitle,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
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
                    const Text(
                      'CONTROL DE ACCESO',
                      style: TextStyle(
                        color: ThemeTokens.textSecondary,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── new password ──────────────────────────────────────
                    _FieldLabel(label: t.auth.newPassword),
                    TextFormField(
                      controller: _newController,
                      obscureText: _obscureNew,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: _ToggleBtn(
                          obscure: _obscureNew,
                          onTap: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? t.auth.invalidPassword : null,
                    ),
                    const SizedBox(height: 16),

                    // ── confirm password ─────────────────────────────────
                    _FieldLabel(label: t.auth.confirmPassword),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: _ToggleBtn(
                          obscure: _obscureConfirm,
                          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) =>
                          v != _newController.text ? t.auth.passwordsDoNotMatch : null,
                    ),
                    const SizedBox(height: 28),

                    // ── save CTA ──────────────────────────────────────────
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ThemeTokens.primary.withOpacity(0.3),
                            blurRadius: 22,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submit,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.lock_reset),
                        label: Text(
                          t.auth.changePassword,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 280.ms).slideY(begin: 0.06, end: 0),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(label, style: const TextStyle(color: ThemeTokens.textSecondary, fontSize: 15)),
  );
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({required this.obscure, required this.onTap});
  final bool obscure;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      color: ThemeTokens.textSecondary,
    ),
    onPressed: onTap,
  );
}
