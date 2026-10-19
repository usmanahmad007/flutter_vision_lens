import 'package:flutter/material.dart';
import '../adapters/vision_ai_adapter.dart';
import '../controllers/vision_lens_controller.dart';
import '../models/vision_lens_mode.dart';
import '../models/vision_object.dart';
import '../models/vision_region.dart';
import '../painters/glowing_border_painter.dart';
import '../painters/reticle_painter.dart';
import '../painters/spotlight_dimmer_painter.dart';
import 'vision_lens_result_sheet.dart';
import 'vision_lens_toolbar.dart';

/// Interactive multimodal lens overlay that wraps any camera stream, image, or UI view,
/// empowering users to tap, lasso, or box-select objects and trigger visual intelligence analysis.
class VisionLensOverlay extends StatefulWidget {
  /// The underlying visual content (Camera preview, Image, or App Screen).
  final Widget child;

  /// The state controller driving the lens.
  final VisionLensController controller;

  /// Optional AI adapter to automatically handle visual queries.
  final VisionAiAdapter? adapter;

  /// Optional custom callback invoked when visual analysis is requested.
  final Future<String> Function(VisionRegion region, String prompt)? onAnalyze;

  /// Whether to display the floating mode selector toolbar.
  final bool showToolbar;

  /// Whether to automatically display the floating result card when a region is selected.
  final bool showResultSheet;

  /// Alignment of the floating mode toolbar.
  final Alignment toolbarAlignment;

  /// Alignment of the floating result sheet.
  final Alignment resultSheetAlignment;

  /// Creates a [VisionLensOverlay].
  const VisionLensOverlay({
    super.key,
    required this.child,
    required this.controller,
    this.adapter,
    this.onAnalyze,
    this.showToolbar = true,
    this.showResultSheet = true,
    this.toolbarAlignment = Alignment.topCenter,
    this.resultSheetAlignment = Alignment.bottomCenter,
  });

  @override
  State<VisionLensOverlay> createState() => _VisionLensOverlayState();
}

class _VisionLensOverlayState extends State<VisionLensOverlay>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _rippleController;

  Offset? _tapPosition;
  Offset? _panStart;
  final List<Offset> _currentLassoPoints = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    widget.controller.addListener(_onControllerChanged);
  }

  void _initAnimations() {
    final style = widget.controller.style;
    _glowController = AnimationController(
      vsync: this,
      duration: style.glowCycleDuration,
    )..repeat();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(VisionLensOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _glowController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _handlePromptExecution(String prompt) async {
    final region = widget.controller.activeRegion;
    if (region == null) return;

    widget.controller.startAnalyzing();

    try {
      String responseText;
      if (widget.onAnalyze != null) {
        responseText = await widget.onAnalyze!(region, prompt);
      } else if (widget.adapter != null) {
        responseText = await widget.adapter!.analyze(
          region: region,
          prompt: prompt,
        );
      } else {
        responseText = 'No AI adapter or onAnalyze handler configured.';
      }

      if (mounted) {
        widget.controller.finishAnalyzing(responseText);
      }
    } catch (e) {
      if (mounted) {
        widget.controller.finishAnalyzing('Analysis error: $e');
      }
    }
  }

  void _handleTapDown(TapDownDetails details, Size size) {
    if (size.isEmpty) return;

    final tapOffset = details.localPosition;
    _tapPosition = tapOffset;
    _rippleController.forward(from: 0.0);

    // 1. Check if user tapped directly on a detected candidate object
    final tappedObject = _findObjectAtOffset(tapOffset, size);
    if (tappedObject != null) {
      widget.controller.selectObject(tappedObject, size);
      return;
    }

    // 2. Otherwise trigger tap-inspect target region
    if (widget.controller.mode == VisionLensMode.tapInspect) {
      widget.controller.selectTapPoint(tapOffset, size);
    }
  }

  VisionObject? _findObjectAtOffset(Offset offset, Size size) {
    for (final obj in widget.controller.detectedObjects) {
      final rect = obj.toScreenRect(size);
      if (rect.contains(offset)) {
        return obj;
      }
    }
    return null;
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    if (size.isEmpty) return;

    _panStart = details.localPosition;

    if (widget.controller.mode == VisionLensMode.lasso) {
      _currentLassoPoints.clear();
      _currentLassoPoints.add(
        Offset(_panStart!.dx / size.width, _panStart!.dy / size.height),
      );
    }
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    if (size.isEmpty || _panStart == null) return;

    final currentPos = details.localPosition;

    if (widget.controller.mode == VisionLensMode.lasso) {
      final normalizedPoint = Offset(
        (currentPos.dx / size.width).clamp(0.0, 1.0),
        (currentPos.dy / size.height).clamp(0.0, 1.0),
      );
      _currentLassoPoints.add(normalizedPoint);
      widget.controller.setLassoPoints(
        List.from(_currentLassoPoints),
        size,
      );
    } else if (widget.controller.mode == VisionLensMode.boundingBox) {
      final left = (_panStart!.dx / size.width).clamp(0.0, 1.0);
      final top = (_panStart!.dy / size.height).clamp(0.0, 1.0);
      final right = (currentPos.dx / size.width).clamp(0.0, 1.0);
      final bottom = (currentPos.dy / size.height).clamp(0.0, 1.0);

      final normalizedRect = Rect.fromLTRB(
        left < right ? left : right,
        top < bottom ? top : bottom,
        left < right ? right : left,
        top < bottom ? bottom : top,
      );

      widget.controller.selectNormalizedRect(normalizedRect, size);
    }
  }

  void _handlePanEnd(DragEndDetails details, Size size) {
    if (widget.controller.mode == VisionLensMode.lasso &&
        _currentLassoPoints.length >= 3) {
      widget.controller.setLassoPoints(
        List.from(_currentLassoPoints),
        size,
      );
    }
    _panStart = null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final activeRegion = controller.activeRegion;
    final style = controller.style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Underlaid Child Content
            widget.child,

            // 2. Gesture Detector Layer
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (details) => _handleTapDown(details, size),
              onPanStart: (details) => _handlePanStart(details, size),
              onPanUpdate: (details) => _handlePanUpdate(details, size),
              onPanEnd: (details) => _handlePanEnd(details, size),
              child: AnimatedBuilder(
                animation: Listenable.merge([_glowController, _rippleController]),
                builder: (context, _) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Spotlight Dimmer outside focus
                      CustomPaint(
                        size: size,
                        painter: SpotlightDimmerPainter(
                          activeRegion: activeRegion,
                          style: style,
                        ),
                      ),

                      // Reticle & Detected Candidates
                      CustomPaint(
                        size: size,
                        painter: ReticlePainter(
                          tapPosition: _tapPosition,
                          detectedObjects: controller.detectedObjects,
                          selectedObject: controller.selectedObject,
                          animationValue: _rippleController.value,
                          style: style,
                        ),
                      ),

                      // Animated Glowing Border around active selection
                      if (activeRegion != null)
                        CustomPaint(
                          size: size,
                          painter: GlowingBorderPainter(
                            activeRegion: activeRegion,
                            style: style,
                            animationValue: _glowController.value,
                            isAnalyzing: controller.isAnalyzing,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),

            // 3. Floating Mode Toolbar
            if (widget.showToolbar)
              SafeArea(
                child: Align(
                  alignment: widget.toolbarAlignment,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: VisionLensToolbar(controller: controller),
                  ),
                ),
              ),

            // 4. Floating Result Sheet
            if (widget.showResultSheet && activeRegion != null)
              SafeArea(
                child: Align(
                  alignment: widget.resultSheetAlignment,
                  child: VisionLensResultSheet(
                    controller: controller,
                    onPromptSelected: _handlePromptExecution,
                    onClose: () {
                      _tapPosition = null;
                      controller.clearSelection();
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
