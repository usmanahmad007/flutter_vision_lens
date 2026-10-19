import 'package:flutter/material.dart';

/// Configures the visual appearance, glow effects, and reticle styles of the vision lens.
class VisionLensStyle {
  /// The primary accent color for active selection borders and handles.
  final Color primaryColor;

  /// Secondary accent color used for multi-color gradients and shimmering effects.
  final Color secondaryColor;

  /// The list of colors used for the animated Apple Intelligence style glowing border.
  final List<Color> glowGradient;

  /// Border width of active selection outlines in logical pixels.
  final double borderWidth;

  /// Corner radius for rectangular bounding boxes.
  final double cornerRadius;

  /// The background dimming opacity outside the focused region (0.0 to 1.0).
  final double spotlightDimOpacity;

  /// Radius of corner adjustment drag handles.
  final double handleRadius;

  /// Color of corner adjustment drag handles.
  final Color handleColor;

  /// Whether to render an animated pulsating glow around the selected region.
  final bool enableGlowAnimation;

  /// Duration of the pulsing glow / breathing cycle.
  final Duration glowCycleDuration;

  /// Creates a custom [VisionLensStyle].
  const VisionLensStyle({
    this.primaryColor = const Color(0xFF00E5FF),
    this.secondaryColor = const Color(0xFFD500F9),
    this.glowGradient = const [
      Color(0xFF00E5FF),
      Color(0xFF7C4DFF),
      Color(0xFFFF4081),
      Color(0xFFFFD700),
      Color(0xFF00E5FF),
    ],
    this.borderWidth = 2.5,
    this.cornerRadius = 12.0,
    this.spotlightDimOpacity = 0.45,
    this.handleRadius = 8.0,
    this.handleColor = Colors.white,
    this.enableGlowAnimation = true,
    this.glowCycleDuration = const Duration(milliseconds: 2400),
  });

  /// Preset inspired by Apple Visual Intelligence with an iridescent glowing neon border.
  factory VisionLensStyle.appleIntelligence() {
    return const VisionLensStyle(
      primaryColor: Color(0xFF00F0FF),
      secondaryColor: Color(0xFFFF2A85),
      glowGradient: [
        Color(0xFF00F0FF),
        Color(0xFF7000FF),
        Color(0xFFFF007A),
        Color(0xFFFFB800),
        Color(0xFF00F0FF),
      ],
      borderWidth: 2.8,
      cornerRadius: 16.0,
      spotlightDimOpacity: 0.50,
      handleRadius: 7.0,
      enableGlowAnimation: true,
      glowCycleDuration: Duration(milliseconds: 2200),
    );
  }

  /// Preset inspired by Google Lens with sleek material accents and clean reticles.
  factory VisionLensStyle.googleLens() {
    return const VisionLensStyle(
      primaryColor: Color(0xFF4285F4),
      secondaryColor: Color(0xFF34A853),
      glowGradient: [
        Color(0xFF4285F4),
        Color(0xFFEA4335),
        Color(0xFFFBBC05),
        Color(0xFF34A853),
        Color(0xFF4285F4),
      ],
      borderWidth: 2.5,
      cornerRadius: 14.0,
      spotlightDimOpacity: 0.40,
      handleRadius: 8.0,
      enableGlowAnimation: true,
      glowCycleDuration: Duration(milliseconds: 2800),
    );
  }

  /// Preset with high-contrast cybernetic neon styling.
  factory VisionLensStyle.cyberpunk() {
    return const VisionLensStyle(
      primaryColor: Color(0xFF00FFCC),
      secondaryColor: Color(0xFFFF0055),
      glowGradient: [
        Color(0xFF00FFCC),
        Color(0xFFFF0055),
        Color(0xFFFFFF00),
        Color(0xFF00FFCC),
      ],
      borderWidth: 3.0,
      cornerRadius: 6.0,
      spotlightDimOpacity: 0.60,
      handleRadius: 9.0,
      enableGlowAnimation: true,
      glowCycleDuration: Duration(milliseconds: 1800),
    );
  }
}
