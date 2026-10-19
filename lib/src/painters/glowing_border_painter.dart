import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/vision_region.dart';
import '../models/vision_style.dart';

/// Custom painter that renders an animated, iridescent neon glowing border
/// and corner handles around the targeted vision region.
class GlowingBorderPainter extends CustomPainter {
  /// The active region to outline.
  final VisionRegion? activeRegion;

  /// The visual styling configuration.
  final VisionLensStyle style;

  /// Normalized animation progress value [0.0 ... 1.0].
  final double animationValue;

  /// Whether an AI analysis task is currently executing.
  final bool isAnalyzing;

  /// Creates a [GlowingBorderPainter].
  GlowingBorderPainter({
    required this.activeRegion,
    required this.style,
    required this.animationValue,
    this.isAnalyzing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (activeRegion == null) return;

    final rect = activeRegion!.screenRect;
    if (rect.isEmpty || rect.width <= 0 || rect.height <= 0) return;

    final sweepAngle = animationValue * 2 * math.pi;

    // Build the path (either rounded rectangle or lasso)
    Path targetPath;
    if (activeRegion!.isLasso && activeRegion!.lassoPoints != null) {
      final points = activeRegion!.lassoPoints!;
      targetPath = Path();
      if (points.isNotEmpty) {
        targetPath.moveTo(
          points.first.dx * size.width,
          points.first.dy * size.height,
        );
        for (int i = 1; i < points.length; i++) {
          targetPath.lineTo(
            points[i].dx * size.width,
            points[i].dy * size.height,
          );
        }
        targetPath.close();
      }
    } else {
      targetPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            rect,
            Radius.circular(style.cornerRadius),
          ),
        );
    }

    final gradientShader = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      transform: GradientRotation(sweepAngle),
      colors: style.glowGradient,
    ).createShader(rect);

    // 1. Draw outer soft glow if animation is enabled
    if (style.enableGlowAnimation) {
      final glowBlur = isAnalyzing ? 16.0 : 9.0;
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.borderWidth * 2.4
        ..shader = gradientShader
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);

      canvas.drawPath(targetPath, glowPaint);
    }

    // 2. Draw crisp foreground stroke
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth
      ..shader = gradientShader;

    canvas.drawPath(targetPath, borderPaint);

    // 3. Draw corner handles (if rectangular bounding box)
    if (!activeRegion!.isLasso) {
      _drawCornerHandles(canvas, rect);
    }
  }

  void _drawCornerHandles(Canvas canvas, Rect rect) {
    final handlePaint = Paint()
      ..color = style.handleColor
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = style.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, style.handleRadius, handlePaint);
      canvas.drawCircle(corner, style.handleRadius, handleBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GlowingBorderPainter oldDelegate) {
    return oldDelegate.activeRegion != activeRegion ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.isAnalyzing != isAnalyzing ||
        oldDelegate.style != style;
  }
}
