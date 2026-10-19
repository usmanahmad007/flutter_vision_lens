import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';

void main() {
  group('VisionLensController Tests', () {
    test('initializes with default values', () {
      final controller = VisionLensController();

      expect(controller.mode, VisionLensMode.tapInspect);
      expect(controller.activeRegion, isNull);
      expect(controller.detectedObjects, isEmpty);
      expect(controller.selectedObject, isNull);
      expect(controller.isAnalyzing, isFalse);
      expect(controller.analysisResult, isNull);
    });

    test('changes mode and notifies listeners', () {
      final controller = VisionLensController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      controller.mode = VisionLensMode.lasso;
      expect(controller.mode, VisionLensMode.lasso);
      expect(notifyCount, 1);

      controller.mode = VisionLensMode.boundingBox;
      expect(controller.mode, VisionLensMode.boundingBox);
      expect(notifyCount, 2);
    });

    test('selectTapPoint creates normalized and screen rects', () {
      final controller = VisionLensController();
      const viewportSize = Size(400, 800);
      const tapPoint = Offset(200, 400);

      controller.selectTapPoint(tapPoint, viewportSize, defaultRadius: 50.0);

      final region = controller.activeRegion;
      expect(region, isNotNull);
      expect(region!.screenRect, const Rect.fromLTRB(150, 350, 250, 450));
      expect(region.normalizedRect.left, closeTo(150 / 400, 0.001));
      expect(region.normalizedRect.top, closeTo(350 / 800, 0.001));
      expect(region.normalizedRect.right, closeTo(250 / 400, 0.001));
      expect(region.normalizedRect.bottom, closeTo(450 / 800, 0.001));
      expect(region.isLasso, isFalse);
    });

    test('setLassoPoints calculates correct bounding rectangle', () {
      final controller = VisionLensController();
      const viewportSize = Size(500, 1000);
      final points = [
        const Offset(0.2, 0.3),
        const Offset(0.6, 0.3),
        const Offset(0.6, 0.7),
        const Offset(0.2, 0.7),
      ];

      controller.setLassoPoints(points, viewportSize);

      final region = controller.activeRegion;
      expect(region, isNotNull);
      expect(region!.isLasso, isTrue);
      expect(region.normalizedRect.left, closeTo(0.2, 0.001));
      expect(region.normalizedRect.top, closeTo(0.3, 0.001));
      expect(region.normalizedRect.right, closeTo(0.6, 0.001));
      expect(region.normalizedRect.bottom, closeTo(0.7, 0.001));
      expect(region.screenRect.left, 100.0);
      expect(region.screenRect.top, 300.0);
      expect(region.screenRect.width, 200.0);
      expect(region.screenRect.height, 400.0);
    });

    test('manages detected objects and selection', () {
      final controller = VisionLensController();
      const obj = VisionObject(
        id: 'obj_1',
        label: 'Sneaker',
        confidence: 0.95,
        normalizedRect: Rect.fromLTWH(0.1, 0.1, 0.3, 0.3),
      );

      controller.setDetectedObjects([obj]);
      expect(controller.detectedObjects.length, 1);

      controller.selectObject(obj, const Size(1000, 1000));
      expect(controller.selectedObject, obj);
      final screenRect = controller.activeRegion!.screenRect;
      expect(screenRect.left, closeTo(100.0, 0.01));
      expect(screenRect.top, closeTo(100.0, 0.01));
      expect(screenRect.width, closeTo(300.0, 0.01));
      expect(screenRect.height, closeTo(300.0, 0.01));
    });

    test('tracks analyzing lifecycle and clears state', () {
      final controller = VisionLensController();

      controller.startAnalyzing();
      expect(controller.isAnalyzing, isTrue);
      expect(controller.analysisResult, isNull);

      controller.finishAnalyzing('AI Output Text');
      expect(controller.isAnalyzing, isFalse);
      expect(controller.analysisResult, 'AI Output Text');

      controller.clearSelection();
      expect(controller.activeRegion, isNull);
      expect(controller.selectedObject, isNull);
      expect(controller.analysisResult, isNull);
      expect(controller.isAnalyzing, isFalse);
    });
  });
}
