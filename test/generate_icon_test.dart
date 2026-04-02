/// Run with: flutter test test/generate_icon_test.dart
/// Generates assets/icons/icon.png and assets/icons/icon_foreground.png
library;

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate app icons', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // 1. Full icon (used for iOS, web, macOS, Windows)
    final iconBytes = await _renderToPng(1024, _drawFullIcon);
    final iconFile = File('assets/icons/icon.png');
    await iconFile.create(recursive: true);
    await iconFile.writeAsBytes(iconBytes);

    // 2. Foreground icon (Android adaptive – transparent background)
    final fgBytes = await _renderToPng(1024, _drawForeground);
    final fgFile = File('assets/icons/icon_foreground.png');
    await fgFile.create(recursive: true);
    await fgFile.writeAsBytes(fgBytes);

    // ignore: avoid_print
    print('✅  Icons written to assets/icons/');
  });
}

// ---------------------------------------------------------------------------
// Render helper
// ---------------------------------------------------------------------------

Future<List<int>> _renderToPng(
  int size,
  void Function(ui.Canvas canvas, double size) draw,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  draw(canvas, size.toDouble());
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

// ---------------------------------------------------------------------------
// Icon variants
// ---------------------------------------------------------------------------

/// Full icon: dark rounded-square background + centred speedometer.
void _drawFullIcon(ui.Canvas canvas, double size) {
  // Background
  final bgPaint = ui.Paint()
    ..color = const ui.Color(0xFF121212)
    ..style = ui.PaintingStyle.fill;
  canvas.drawRRect(
    ui.RRect.fromRectAndRadius(
      ui.Rect.fromLTWH(0, 0, size, size),
      ui.Radius.circular(size * 0.22),
    ),
    bgPaint,
  );

  _drawSpeedometer(
    canvas,
    center: ui.Offset(size * 0.5, size * 0.52),
    radius: size * 0.355,
  );
}

/// Foreground icon: transparent background + speedometer (Android adaptive).
/// Kept slightly smaller so the graphic stays inside Android's safe zone.
void _drawForeground(ui.Canvas canvas, double size) {
  _drawSpeedometer(
    canvas,
    center: ui.Offset(size * 0.5, size * 0.52),
    radius: size * 0.30,
  );
}

// ---------------------------------------------------------------------------
// Speedometer drawing
// ---------------------------------------------------------------------------

void _drawSpeedometer(
  ui.Canvas canvas, {
  required ui.Offset center,
  required double radius,
}) {
  // ── outer orange arc ────────────────────────────────────────────────────
  final arcPaint = ui.Paint()
    ..color = const ui.Color(0xFFFF5722)
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeWidth = radius * 0.155;

  canvas.drawArc(
    ui.Rect.fromCircle(center: center, radius: radius),
    math.pi * 0.06,
    math.pi * 1.76,
    false,
    arcPaint,
  );

  // ── inner tick dashes ────────────────────────────────────────────────────
  final dashPaint = ui.Paint()
    ..color = const ui.Color(0xFF3A3A3A)
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeWidth = radius * 0.13;

  final dashRadius = radius * 0.57;
  const dashCount = 10;
  const dashSweep = 0.11;
  const dashGap = 0.14;
  var angle = math.pi * 0.96;
  for (var i = 0; i < dashCount; i++) {
    canvas.drawArc(
      ui.Rect.fromCircle(center: center, radius: dashRadius),
      angle,
      dashSweep,
      false,
      dashPaint,
    );
    angle += dashSweep + dashGap;
  }

  // ── needle ───────────────────────────────────────────────────────────────
  final needlePaint = ui.Paint()
    ..color = const ui.Color(0xFFFFFFFF)
    ..style = ui.PaintingStyle.stroke
    ..strokeCap = ui.StrokeCap.round
    ..strokeWidth = radius * 0.145;

  const needleAngle = -math.pi * 0.38;
  final needleLength = radius * 0.52;
  final needleEnd = ui.Offset(
    center.dx + math.cos(needleAngle) * needleLength,
    center.dy + math.sin(needleAngle) * needleLength,
  );
  canvas.drawLine(center, needleEnd, needlePaint);

  // ── centre dot ───────────────────────────────────────────────────────────
  canvas.drawCircle(
    center,
    radius * 0.14,
    ui.Paint()..color = const ui.Color(0xFFFF5722),
  );
}

