import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Represents a targeted spatial region selected for visual intelligence analysis.
class VisionRegion {
  /// The normalized bounding rectangle in the range [0.0 ... 1.0].
  final Rect normalizedRect;

  /// The absolute screen pixel rectangle within the active viewport.
  final Rect screenRect;

  /// Optional freehand lasso contour points in normalized coordinates, if selected via lasso.
  final List<Offset>? lassoPoints;

  /// The cropped image payload in JPEG or PNG byte format, if extraction was requested.
  final Uint8List? imageBytes;

  /// The original pixel dimensions of the source image or camera frame.
  final Size? sourceImageSize;

  /// The pixel dimensions of the interactive screen viewport.
  final Size viewportSize;

  /// Timestamp when this region was captured.
  final DateTime timestamp;

  /// Creates a [VisionRegion] representing an area of visual interest.
  VisionRegion({
    required this.normalizedRect,
    required this.screenRect,
    this.lassoPoints,
    this.imageBytes,
    this.sourceImageSize,
    required this.viewportSize,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Whether this region was selected via a freehand lasso contour.
  bool get isLasso => lassoPoints != null && lassoPoints!.length >= 3;

  /// Returns the aspect ratio (width / height) of this region.
  double get aspectRatio =>
      normalizedRect.height > 0 ? normalizedRect.width / normalizedRect.height : 1.0;

  /// Creates a copy of this region with optional updated fields.
  VisionRegion copyWith({
    Rect? normalizedRect,
    Rect? screenRect,
    List<Offset>? lassoPoints,
    Uint8List? imageBytes,
    Size? sourceImageSize,
    Size? viewportSize,
    DateTime? timestamp,
  }) {
    return VisionRegion(
      normalizedRect: normalizedRect ?? this.normalizedRect,
      screenRect: screenRect ?? this.screenRect,
      lassoPoints: lassoPoints ?? this.lassoPoints,
      imageBytes: imageBytes ?? this.imageBytes,
      sourceImageSize: sourceImageSize ?? this.sourceImageSize,
      viewportSize: viewportSize ?? this.viewportSize,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
