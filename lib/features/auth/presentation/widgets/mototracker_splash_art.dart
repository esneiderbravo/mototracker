import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/theme_tokens.dart';

/// Animated MotoTracker splash graphic.
///
/// Sequence (total ~1 800 ms):
///  0 –  55 % → outer arc traces itself (easeOut)
/// 10 –  75 % → needle revs from idle to running RPM (easeOutBack overshoot)
/// 25 –  65 % → tick dashes fade in
/// 45 –  70 % → centre dot bounces in (elasticOut)
/// 65 – 100 % → app-name + tagline slide-fade in (flutter_animate)
class MotoTrackerSplashArt extends StatefulWidget {
  const MotoTrackerSplashArt({super.key});

  @override
  State<MotoTrackerSplashArt> createState() => _MotoTrackerSplashArtState();
}

class _MotoTrackerSplashArtState extends State<MotoTrackerSplashArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _arcAnim;
  late final Animation<double> _needleAnim;
  late final Animation<double> _dashAnim;
  late final Animation<double> _dotAnim;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _arcAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _needleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.10, 0.75, curve: Curves.easeOutBack),
    );

    _dashAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.65, curve: Curves.easeIn),
    );

    _dotAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.45, 0.70, curve: Curves.elasticOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── animated speedometer ──────────────────────────────────────────
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, _) => SizedBox(
            width: 170,
            height: 170,
            child: CustomPaint(
              painter: _SpeedometerPainter(
                arcProgress: _arcAnim.value,
                needleProgress: _needleAnim.value,
                dashOpacity: _dashAnim.value,
                dotScale: _dotAnim.value,
              ),
            ),
          ),
        ),

        const SizedBox(height: 22),

        // ── app name ─────────────────────────────────────────────────────
        RichText(
          text: TextSpan(
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
            children: const [
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
        )
            .animate(delay: 1100.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),

        const SizedBox(height: 14),

        // ── tagline ───────────────────────────────────────────────────────
        Text(
          'RIDE. TRACK. CONNECT.',
          style: textTheme.bodyMedium?.copyWith(
            color: ThemeTokens.textSecondary,
            letterSpacing: 4,
            fontWeight: FontWeight.w600,
          ),
        )
            .animate(delay: 1300.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),
      ],
    );
  }
}

// ── Custom Painter ────────────────────────────────────────────────────────────

class _SpeedometerPainter extends CustomPainter {
  const _SpeedometerPainter({
    required this.arcProgress,
    required this.needleProgress,
    required this.dashOpacity,
    required this.dotScale,
  });

  final double arcProgress;    // 0 → 1  (outer arc sweep)
  final double needleProgress; // 0 → 1  (idle → running, may overshoot)
  final double dashOpacity;    // 0 → 1  (tick-mark alpha)
  final double dotScale;       // 0 → 1+ (centre dot scale, may overshoot)

  // Arc geometry – matches the static original
  static const _arcStart = math.pi * 0.06;
  static const _arcSweep = math.pi * 1.76;

  // Needle positions
  static const _needleIdle    =  math.pi * 0.85; // ~6 o'clock-ish → idle RPM
  static const _needleRunning = -math.pi * 0.38; // upper-left      → cruising RPM

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // 1 ── outer arc (traces itself from start) ───────────────────────────
    if (arcProgress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        _arcStart,
        _arcSweep * arcProgress,
        false,
        Paint()
          ..color = ThemeTokens.primary
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10,
      );
    }

    // 2 ── inner tick dashes (fade in as a group) ─────────────────────────
    if (dashOpacity > 0) {
      final dashPaint = Paint()
        ..color = ThemeTokens.surfaceHighlight.withValues(alpha: dashOpacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 8;

      final dashRadius = radius * 0.57;
      const dashCount = 10;
      const dashSweep = 0.11;
      const dashGap = 0.14;
      var angle = math.pi * 0.96;
      for (var i = 0; i < dashCount; i++) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: dashRadius),
          angle,
          dashSweep,
          false,
          dashPaint,
        );
        angle += dashSweep + dashGap;
      }
    }

    // 3 ── needle (revs from idle → running, easeOutBack overshoot) ───────
    if (needleProgress > 0) {
      final currentAngle =
          _needleIdle + (_needleRunning - _needleIdle) * needleProgress;
      final needleLength = radius * 0.5;
      final needleEnd = Offset(
        center.dx + math.cos(currentAngle) * needleLength,
        center.dy + math.sin(currentAngle) * needleLength,
      );

      canvas.drawLine(
        center,
        needleEnd,
        Paint()
          ..color = ThemeTokens.textPrimary
              .withValues(alpha: needleProgress.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 10,
      );
    }

    // 4 ── centre dot (elasticOut bounce on entry) ─────────────────────────
    if (dotScale > 0) {
      canvas.drawCircle(
        center,
        12 * math.max(0.0, dotScale), // elasticOut can exceed 1 – that's the bounce
        Paint()..color = ThemeTokens.primary,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedometerPainter old) =>
      old.arcProgress    != arcProgress    ||
      old.needleProgress != needleProgress ||
      old.dashOpacity    != dashOpacity    ||
      old.dotScale       != dotScale;
}
