import 'package:flutter/material.dart';
import '../models/vision_lens_mode.dart';
import '../models/vision_object.dart';
import '../models/vision_region.dart';
import '../models/vision_style.dart';

/// Central controller that manages interactive selection, detected objects,
/// visual styling, and multimodal analysis lifecycle.
class VisionLensController extends ChangeNotifier {
  VisionLensMode _mode;
  VisionRegion? _activeRegion;
  List<VisionObject> _detectedObjects;
  VisionObject? _selectedObject;
  bool _isAnalyzing = false;
  String? _analysisResult;
  VisionLensStyle _style;

  /// Creates a [VisionLensController] with initial configuration.
  VisionLensController({
    VisionLensMode initialMode = VisionLensMode.tapInspect,
    VisionLensStyle? style,
    List<VisionObject>? initialObjects,
  })  : _mode = initialMode,
        _style = style ?? VisionLensStyle.appleIntelligence(),
        _detectedObjects = List.unmodifiable(initialObjects ?? const []);

  /// The active interactive mode (tap, lasso, box, auto-detect).
  VisionLensMode get mode => _mode;

  /// Sets the active mode and notifies listeners.
  set mode(VisionLensMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  /// The currently focused or selected spatial region.
  VisionRegion? get activeRegion => _activeRegion;

  /// The list of detected objects currently known to the lens.
  List<VisionObject> get detectedObjects => _detectedObjects;

  /// The currently selected detected object, if any.
  VisionObject? get selectedObject => _selectedObject;

  /// Whether an AI analysis task is currently executing.
  bool get isAnalyzing => _isAnalyzing;

  /// The most recent analysis output text or markdown.
  String? get analysisResult => _analysisResult;

  /// The styling configuration used by the visual lens overlay.
  VisionLensStyle get style => _style;

  /// Sets the styling configuration and triggers a redraw.
  set style(VisionLensStyle newStyle) {
    _style = newStyle;
    notifyListeners();
  }

  /// Sets the active region directly.
  void selectRegion(VisionRegion region) {
    _activeRegion = region;
    notifyListeners();
  }

  /// Selects a normalized rectangle in the viewport.
  void selectNormalizedRect(Rect normalizedRect, Size viewportSize) {
    final screenRect = Rect.fromLTWH(
      normalizedRect.left * viewportSize.width,
      normalizedRect.top * viewportSize.height,
      normalizedRect.width * viewportSize.width,
      normalizedRect.height * viewportSize.height,
    );
    _activeRegion = VisionRegion(
      normalizedRect: normalizedRect,
      screenRect: screenRect,
      viewportSize: viewportSize,
    );
    notifyListeners();
  }

  /// Selects a tap point, forming a circular/rounded target region around it.
  void selectTapPoint(
    Offset tapPoint,
    Size viewportSize, {
    double defaultRadius = 45.0,
  }) {
    final left = (tapPoint.dx - defaultRadius).clamp(0.0, viewportSize.width);
    final top = (tapPoint.dy - defaultRadius).clamp(0.0, viewportSize.height);
    final right = (tapPoint.dx + defaultRadius).clamp(0.0, viewportSize.width);
    final bottom = (tapPoint.dy + defaultRadius).clamp(0.0, viewportSize.height);

    final screenRect = Rect.fromLTRB(left, top, right, bottom);
    final normalizedRect = Rect.fromLTRB(
      screenRect.left / viewportSize.width,
      screenRect.top / viewportSize.height,
      screenRect.right / viewportSize.width,
      screenRect.bottom / viewportSize.height,
    );

    _activeRegion = VisionRegion(
      normalizedRect: normalizedRect,
      screenRect: screenRect,
      viewportSize: viewportSize,
    );
    notifyListeners();
  }

  /// Sets the active selection from freehand lasso contour points.
  void setLassoPoints(List<Offset> normalizedPoints, Size viewportSize) {
    if (normalizedPoints.isEmpty) return;

    double minX = 1.0, minY = 1.0, maxX = 0.0, maxY = 0.0;
    for (final p in normalizedPoints) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    final normalizedRect = Rect.fromLTRB(
      minX.clamp(0.0, 1.0),
      minY.clamp(0.0, 1.0),
      maxX.clamp(0.0, 1.0),
      maxY.clamp(0.0, 1.0),
    );

    final screenRect = Rect.fromLTWH(
      normalizedRect.left * viewportSize.width,
      normalizedRect.top * viewportSize.height,
      normalizedRect.width * viewportSize.width,
      normalizedRect.height * viewportSize.height,
    );

    _activeRegion = VisionRegion(
      normalizedRect: normalizedRect,
      screenRect: screenRect,
      lassoPoints: normalizedPoints,
      viewportSize: viewportSize,
    );
    notifyListeners();
  }

  /// Updates the detected objects recognized by on-device or cloud detectors.
  void setDetectedObjects(List<VisionObject> objects) {
    _detectedObjects = List.unmodifiable(objects);
    notifyListeners();
  }

  /// Focuses and selects a specific detected object.
  void selectObject(VisionObject object, Size viewportSize) {
    _selectedObject = object;
    selectNormalizedRect(object.normalizedRect, viewportSize);
  }

  /// Sets the controller into an analyzing state.
  void startAnalyzing() {
    _isAnalyzing = true;
    _analysisResult = null;
    notifyListeners();
  }

  /// Completes the analysis with the provided result string.
  void finishAnalyzing(String result) {
    _isAnalyzing = false;
    _analysisResult = result;
    notifyListeners();
  }

  /// Clears the active selection, analysis result, and selected object.
  void clearSelection() {
    _activeRegion = null;
    _selectedObject = null;
    _analysisResult = null;
    _isAnalyzing = false;
    notifyListeners();
  }

  /// Resets the controller back to initial state.
  void reset() {
    clearSelection();
    _detectedObjects = const [];
    notifyListeners();
  }
}
