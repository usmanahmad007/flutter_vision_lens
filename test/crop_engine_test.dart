import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';

void main() {
  group('VisionCropEngine Tests', () {
    test('mapNormalizedRectToImage scales properly', () {
      const normalizedRect = Rect.fromLTWH(0.25, 0.5, 0.5, 0.25);
      const imageSize = Size(1920, 1080);

      final pixelRect = VisionCropEngine.mapNormalizedRectToImage(
        normalizedRect: normalizedRect,
        imageSize: imageSize,
      );

      expect(pixelRect.left, 480.0);
      expect(pixelRect.top, 540.0);
      expect(pixelRect.width, 960.0);
      expect(pixelRect.height, 270.0);
    });

    test('mapScreenPointToImage with contain aspect ratio fitting', () {
      const screenSize = Size(500, 500);
      const imageSize = Size(1000, 1000);
      const screenPoint = Offset(250, 250);

      final point = VisionCropEngine.mapScreenPointToImage(
        screenPoint: screenPoint,
        screenSize: screenSize,
        imageSize: imageSize,
        fit: BoxFit.contain,
      );

      expect(point.dx, 500.0);
      expect(point.dy, 500.0);
    });

    test('mapScreenRectToImage with BoxFit.contain handles letterboxing', () {
      const screenSize = Size(1000, 1000);
      const imageSize = Size(1920, 1080); // 16:9 aspect ratio

      final mapped = VisionCropEngine.mapScreenRectToImage(
        screenRect: const Rect.fromLTWH(0, 0, 1000, 1000),
        screenSize: screenSize,
        imageSize: imageSize,
        fit: BoxFit.contain,
      );

      expect(mapped.width, 1920.0);
      expect(mapped.height, 1080.0);
    });
  });
}
