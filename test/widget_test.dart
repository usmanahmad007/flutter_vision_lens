import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';

void main() {
  group('VisionLens Widget Tests', () {
    testWidgets('renders child content and toolbar', (tester) async {
      final controller = VisionLensController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisionLensOverlay(
              controller: controller,
              adapter: const MockVisionAdapter(simulatedDelay: Duration.zero),
              child: const Center(child: Text('Camera Viewport Simulation')),
            ),
          ),
        ),
      );

      expect(find.text('Camera Viewport Simulation'), findsOneWidget);
      expect(find.byType(VisionLensToolbar), findsOneWidget);
      expect(find.byIcon(Icons.touch_app_rounded), findsOneWidget);
      expect(find.byIcon(Icons.gesture_rounded), findsOneWidget);
      expect(find.byIcon(Icons.crop_free_rounded), findsOneWidget);
    });

    testWidgets('switches mode via toolbar buttons', (tester) async {
      final controller = VisionLensController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisionLensOverlay(
              controller: controller,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(controller.mode, VisionLensMode.tapInspect);

      // Tap lasso button
      await tester.tap(find.byIcon(Icons.gesture_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.mode, VisionLensMode.lasso);

      // Tap bounding box button
      await tester.tap(find.byIcon(Icons.crop_free_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller.mode, VisionLensMode.boundingBox);
    });

    testWidgets('tap gesture creates active region and shows result sheet', (tester) async {
      final controller = VisionLensController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VisionLensOverlay(
              controller: controller,
              adapter: const MockVisionAdapter(simulatedDelay: Duration.zero),
              autoCropImage: false,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );

      expect(find.byType(VisionLensResultSheet), findsNothing);

      // Tap in center of screen
      await tester.tapAt(const Offset(300, 300));
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.activeRegion, isNotNull);
      expect(find.byType(VisionLensResultSheet), findsOneWidget);
      expect(find.text('Visual Intelligence'), findsOneWidget);

      // Tap Explain prompt chip
      await tester.tap(find.text('Explain'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(controller.analysisResult, contains('Visual Intelligence Insights'));
    });
  });
}
