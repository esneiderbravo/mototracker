import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_tokens.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/app_alerts.dart';
import '../providers/auth_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      if (_isSignUp) {
        await repo.signUp(email: _emailController.text.trim(), password: _passwordController.text);
      } else {
        await repo.signIn(email: _emailController.text.trim(), password: _passwordController.text);
      }
      if (!mounted) return;
      context.go('/garage');
    } catch (e) {
      if (!mounted) return;
      final t = Translations.of(context);
      AppAlerts.error(
        context,
        message: _isSignUp ? t.auth.signUpError : t.auth.signInError,
        detail: e,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── decorative glows ───────────────────────────────────────────
          Positioned(
            top: -130,
            right: -130,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x2EFF5722), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -110,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Color(0x12FF5722), Colors.transparent]),
              ),
            ),
          ),

          // ── content ────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // ── logo ───────────────────────────────────────────
                      const _MotoLogo()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.12, end: 0, duration: 400.ms, curve: Curves.easeOut),

                      const SizedBox(height: 44),

                      // ── mode tabs ──────────────────────────────────────
                      _ModeSwitch(
                            isSignUp: _isSignUp,
                            signInLabel: t.auth.signIn,
                            signUpLabel: t.auth.signUp,
                            enabled: !_isLoading,
                            onChanged: (v) => setState(() => _isSignUp = v),
                          )
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.1, end: 0, duration: 350.ms),

                      const SizedBox(height: 28),

                      // ── form ───────────────────────────────────────────
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // email
                            TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: t.auth.email,
                                    prefixIcon: const Icon(
                                      Icons.alternate_email_rounded,
                                      size: 20,
                                      color: ThemeTokens.textSecondary,
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || !v.contains('@')) ? t.auth.invalidEmail : null,
                                )
                                .animate(delay: 140.ms)
                                .fadeIn(duration: 350.ms)
                                .slideX(begin: 0.06, end: 0, duration: 350.ms),

                            const SizedBox(height: 14),

                            // password
                            TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (!_isLoading) _submit();
                                  },
                                  decoration: InputDecoration(
                                    labelText: t.auth.password,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 20,
                                      color: ThemeTokens.textSecondary,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 20,
                                        color: ThemeTokens.textSecondary,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  validator: (v) =>
                                      (v == null || v.length < 6) ? t.auth.invalidPassword : null,
                                )
                                .animate(delay: 200.ms)
                                .fadeIn(duration: 350.ms)
                                .slideX(begin: 0.06, end: 0, duration: 350.ms),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ── CTA button ─────────────────────────────────────
                      _SubmitButton(
                            isLoading: _isLoading,
                            label: _isSignUp ? t.auth.signUp : t.auth.signIn,
                            onTap: _isLoading ? null : _submit,
                          )
                          .animate(delay: 260.ms)
                          .fadeIn(duration: 350.ms)
                          .slideY(begin: 0.1, end: 0, duration: 350.ms),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo header
// ─────────────────────────────────────────────────────────────────────────────

class _MotoLogo extends StatelessWidget {
  const _MotoLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // static mini speedometer
        const SizedBox(
          width: 90,
          height: 90,
          child: CustomPaint(painter: _SpeedometerIconPainter()),
        ),
        const SizedBox(height: 18),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 2),
            children: [
              TextSpan(
                text: 'MOTO',
                style: TextStyle(color: ThemeTokens.textPrimary),
              ),
              TextSpan(
                text: 'TRACKER',
                style: TextStyle(color: ThemeTokens.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'RIDE. TRACK. CONNECT.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ThemeTokens.textSecondary,
            fontSize: 11,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static mini speedometer painter
// ─────────────────────────────────────────────────────────────────────────────

class _SpeedometerIconPainter extends CustomPainter {
  const _SpeedometerIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // outer orange arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.06,
      math.pi * 1.76,
      false,
      Paint()
        ..color = ThemeTokens.primary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7,
    );

    // inner tick dashes
    final dashPaint = Paint()
      ..color = ThemeTokens.surfaceHighlight
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;
    var angle = math.pi * 0.96;
    for (var i = 0; i < 10; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.57),
        angle,
        0.11,
        false,
        dashPaint,
      );
      angle += 0.25;
    }

    // needle
    const needleAngle = -math.pi * 0.38;
    final nl = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(center.dx + math.cos(needleAngle) * nl, center.dy + math.sin(needleAngle) * nl),
      Paint()
        ..color = ThemeTokens.textPrimary
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7,
    );

    // centre dot
    canvas.drawCircle(center, 9, Paint()..color = ThemeTokens.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Segmented mode switcher
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({
    required this.isSignUp,
    required this.signInLabel,
    required this.signUpLabel,
    required this.onChanged,
    required this.enabled,
  });

  final bool isSignUp;
  final String signInLabel;
  final String signUpLabel;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ThemeTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeTokens.border),
      ),
      child: Row(
        children: [
          _Tab(
            label: signInLabel,
            selected: !isSignUp,
            onTap: enabled ? () => onChanged(false) : null,
          ),
          _Tab(
            label: signUpLabel,
            selected: isSignUp,
            onTap: enabled ? () => onChanged(true) : null,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected ? ThemeTokens.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: selected ? ThemeTokens.textPrimary : ThemeTokens.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Submit button
// ─────────────────────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.label, required this.onTap});

  final bool isLoading;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeTokens.primary,
          foregroundColor: ThemeTokens.textPrimary,
          disabledBackgroundColor: ThemeTokens.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(ThemeTokens.textPrimary),
                  ),
                )
              : Text(key: const ValueKey('label'), label),
        ),
      ),
    );
  }
}
