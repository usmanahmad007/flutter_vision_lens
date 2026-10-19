import 'package:flutter/material.dart';

/// Represents a detected or classified object within the vision viewport.
class VisionObject {
  /// Unique identifier for the detected object.
  final String id;

  /// Human-readable label or classification (e.g. 'Sneakers', 'Document', 'Laptop').
  final String label;

  /// Detection confidence score between 0.0 and 1.0.
  final double confidence;

  /// Bounding rectangle in normalized coordinates [0.0 ... 1.0].
  ///
  /// For instance, `Rect.fromLTWH(0.2, 0.3, 0.4, 0.4)` covers the area
  /// from 20% to 60% of the viewport width, and 30% to 70% of the viewport height.
  final Rect normalizedRect;

  /// Optional custom highlight color for this specific entity.
  final Color? highlightColor;

  /// Arbitrary metadata attached by an inference model or classifier.
  final Map<String, dynamic>? metadata;

  /// Creates a new [VisionObject] instance.
  const VisionObject({
    required this.id,
    required this.label,
    this.confidence = 1.0,
    required this.normalizedRect,
    this.highlightColor,
    this.metadata,
  });

  /// Converts the normalized coordinates to absolute screen pixel coordinates.
  Rect toScreenRect(Size viewportSize) {
    return Rect.fromLTWH(
      normalizedRect.left * viewportSize.width,
      normalizedRect.top * viewportSize.height,
      normalizedRect.width * viewportSize.width,
      normalizedRect.height * viewportSize.height,
    );
  }

  /// Creates a copy of this object with optional replacement properties.
  VisionObject copyWith({
    String? id,
    String? label,
    double? confidence,
    Rect? normalizedRect,
    Color? highlightColor,
    Map<String, dynamic>? metadata,
  }) {
    return VisionObject(
      id: id ?? this.id,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      normalizedRect: normalizedRect ?? this.normalizedRect,
      highlightColor: highlightColor ?? this.highlightColor,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisionObject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          confidence == other.confidence &&
          normalizedRect == other.normalizedRect;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      confidence.hashCode ^
      normalizedRect.hashCode;
}
