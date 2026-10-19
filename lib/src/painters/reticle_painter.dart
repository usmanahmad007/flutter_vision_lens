import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/vision_object.dart';
import '../models/vision_style.dart';

/// Custom painter for tap-to-focus target reticles, expanding ripples,
/// and detected object candidate brackets.
class ReticlePainter extends CustomPainter {
  /// The tap position in viewport coordinates, if any.
  final Offset? tapPosition;

  /// The list of detected objects to draw candidate highlights for.
  final List<VisionObject> detectedObjects;

  /// The currently selected detected object.
  final VisionObject? selectedObject;

  /// Animation progress for the pulsing target reticle [0.0 ... 1.0].
  final double animationValue;

  /// Visual styling configuration.
  final VisionLensStyle style;

  /// Creates a [ReticlePainter].
  ReticlePainter({
    required this.tapPosition,
    required this.detectedObjects,
    required this.selectedObject,
    required this.animationValue,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw candidate brackets for detected objects (when not focused)
    for (final obj in detectedObjects) {
      if (obj == selectedObject) continue;
      _drawCandidateObject(canvas, obj, size);
    }

    // 2. Draw active tap reticle if a point is tapped
    if (tapPosition != null) {
      _drawTapReticle(canvas, tapPosition!);
    }
  }

  void _drawCandidateObject(Canvas canvas, VisionObject obj, Size size) {
    final rect = obj.toScreenRect(size);
    final color = obj.highlightColor ?? style.primaryColor;

    final bracketPaint = Paint()
      ..color = color.withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const bracketLen = 14.0;

    // Top-Left corner
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, bracketLen), bracketPaint);

    // Top-Right corner
    canvas.drawLine(rect.topRight, rect.topRight - const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, bracketLen), bracketPaint);

    // Bottom-Left corner
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft - const Offset(0, bracketLen), bracketPaint);

    // Bottom-Right corner
    canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(bracketLen, 0), bracketPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight - const Offset(0, bracketLen), bracketPaint);

    // Optional text badge above candidate
    if (obj.label.isNotEmpty) {
      final textSpan = TextSpan(
        text: ' ${obj.label} ',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          background: Paint()
            ..color = Colors.black.withAlpha(150)
            ..style = PaintingStyle.fill,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, math.max(0, rect.top - 16)),
      );
    }
  }

  void _drawTapReticle(Canvas canvas, Offset center) {
    const baseRadius = 24.0;
    final rippleRadius = baseRadius + (animationValue * 22.0);
    final rippleAlpha = ((1.0 - animationValue) * 180).round().clamp(0, 255);

    // Ripple wave
    final ripplePaint = Paint()
      ..color = style.primaryColor.withAlpha(rippleAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, rippleRadius, ripplePaint);

    // Center focal dot
    final centerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, centerDotPaint);

    // Reticle ring
    final ringPaint = Paint()
      ..color = style.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, baseRadius, ringPaint);

    // 4 Crosshair ticks
    final tickPaint = Paint()
      ..color = style.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const tickDist = 28.0;
    const tickLen = 7.0;

    // Top
    canvas.drawLine(center - const Offset(0, tickDist), center - const Offset(0, tickDist - tickLen), tickPaint);
    // Bottom
    canvas.drawLine(center + const Offset(0, tickDist - tickLen), center + const Offset(0, tickDist), tickPaint);
    // Left
    canvas.drawLine(center - const Offset(tickDist, 0), center - const Offset(tickDist - tickLen, 0), tickPaint);
    // Right
    canvas.drawLine(center + const Offset(tickDist - tickLen, 0), center + const Offset(tickDist, 0), tickPaint);
  }

  @override
  bool shouldRepaint(covariant ReticlePainter oldDelegate) {
    return oldDelegate.tapPosition != tapPosition ||
        oldDelegate.detectedObjects != detectedObjects ||
        oldDelegate.selectedObject != selectedObject ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.style != style;
  }
}
