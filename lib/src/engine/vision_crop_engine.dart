import 'package:flutter/material.dart';

/// Coordinate mapping and image transformation engine for visual intelligence operations.
class VisionCropEngine {
  /// Maps a viewport [screenRect] to the corresponding sub-rect in source image pixels,
  /// accounting for aspect ratio fitting ([BoxFit]).
  static Rect mapScreenRectToImage({
    required Rect screenRect,
    required Size screenSize,
    required Size imageSize,
    BoxFit fit = BoxFit.contain,
  }) {
    if (screenSize.isEmpty || imageSize.isEmpty) return Rect.zero;

    final fittedSizes = applyBoxFit(fit, imageSize, screenSize);
    final destinationSize = fittedSizes.destination;

    // Calculate letterboxing or pillarboxing offsets
    final dx = (screenSize.width - destinationSize.width) / 2.0;
    final dy = (screenSize.height - destinationSize.height) / 2.0;

    // Normalize against the destination drawing rect
    final scaleX = imageSize.width / destinationSize.width;
    final scaleY = imageSize.height / destinationSize.height;

    final imageLeft = ((screenRect.left - dx) * scaleX).clamp(0.0, imageSize.width);
    final imageTop = ((screenRect.top - dy) * scaleY).clamp(0.0, imageSize.height);
    final imageRight = ((screenRect.right - dx) * scaleX).clamp(0.0, imageSize.width);
    final imageBottom = ((screenRect.bottom - dy) * scaleY).clamp(0.0, imageSize.height);

    final width = (imageRight - imageLeft).clamp(0.0, imageSize.width);
    final height = (imageBottom - imageTop).clamp(0.0, imageSize.height);

    return Rect.fromLTWH(imageLeft, imageTop, width, height);
  }

  /// Maps a point from screen viewport coordinates to image pixel coordinates.
  static Offset mapScreenPointToImage({
    required Offset screenPoint,
    required Size screenSize,
    required Size imageSize,
    BoxFit fit = BoxFit.contain,
  }) {
    final fittedSizes = applyBoxFit(fit, imageSize, screenSize);
    final destinationSize = fittedSizes.destination;

    final dx = (screenSize.width - destinationSize.width) / 2.0;
    final dy = (screenSize.height - destinationSize.height) / 2.0;

    final scaleX = imageSize.width / destinationSize.width;
    final scaleY = imageSize.height / destinationSize.height;

    final px = ((screenPoint.dx - dx) * scaleX).clamp(0.0, imageSize.width);
    final py = ((screenPoint.dy - dy) * scaleY).clamp(0.0, imageSize.height);

    return Offset(px, py);
  }

  /// Converts a normalized rectangle [0.0 ... 1.0] to image pixel coordinates.
  static Rect mapNormalizedRectToImage({
    required Rect normalizedRect,
    required Size imageSize,
  }) {
    return Rect.fromLTWH(
      normalizedRect.left * imageSize.width,
      normalizedRect.top * imageSize.height,
      normalizedRect.width * imageSize.width,
      normalizedRect.height * imageSize.height,
    );
  }
}
