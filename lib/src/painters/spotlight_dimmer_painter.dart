import 'package:flutter/material.dart';
import '../models/vision_region.dart';
import '../models/vision_style.dart';

/// Custom painter that darkens the viewport area outside the selected region,
/// creating a focused spotlight effect on the targeted object.
class SpotlightDimmerPainter extends CustomPainter {
  /// The active region to cut out and keep illuminated.
  final VisionRegion? activeRegion;

  /// The visual styling specifying dimming opacity and corner rounding.
  final VisionLensStyle style;

  /// Creates a [SpotlightDimmerPainter].
  SpotlightDimmerPainter({
    required this.activeRegion,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (activeRegion == null) return;

    final screenRect = activeRegion!.screenRect;
    if (screenRect.isEmpty || screenRect.width <= 0 || screenRect.height <= 0) {
      return;
    }

    final fullCanvasPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    Path holePath;
    if (activeRegion!.isLasso && activeRegion!.lassoPoints != null) {
      final points = activeRegion!.lassoPoints!;
      holePath = Path();
      if (points.isNotEmpty) {
        holePath.moveTo(
          points.first.dx * size.width,
          points.first.dy * size.height,
        );
        for (int i = 1; i < points.length; i++) {
          holePath.lineTo(
            points[i].dx * size.width,
            points[i].dy * size.height,
          );
        }
        holePath.close();
      }
    } else {
      holePath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            screenRect,
            Radius.circular(style.cornerRadius),
          ),
        );
    }

    final dimmedPath = Path.combine(
      PathOperation.difference,
      fullCanvasPath,
      holePath,
    );

    final dimPaint = Paint()
      ..color = Colors.black.withAlpha((style.spotlightDimOpacity * 255).round())
      ..style = PaintingStyle.fill;

    canvas.drawPath(dimmedPath, dimPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightDimmerPainter oldDelegate) {
    return oldDelegate.activeRegion != activeRegion ||
        oldDelegate.style != style;
  }
}
