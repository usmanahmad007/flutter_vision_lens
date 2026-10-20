# Flutter Vision Lens 🔍✨

[![pub package](https://img.shields.io/pub/v/flutter_vision_lens.svg)](https://pub.dev/packages/flutter_vision_lens)
[![CI](https://github.com/usmanahmad007/flutter_vision_lens/actions/workflows/ci.yml/badge.svg)](https://github.com/usmanahmad007/flutter_vision_lens/actions)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/usmanahmad007/flutter_vision_lens/blob/main/LICENSE)
[![Platforms](https://img.shields.io/badge/platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue)](https://pub.dev/packages/flutter_vision_lens)

An interactive, high-performance **Apple Visual Intelligence** and **Google Lens** style multimodal camera and image overlay for Flutter.

Empower your users to **tap on objects**, **draw freehand lasso loops**, or **drag bounding boxes** directly on top of live camera streams, gallery images, or in-app screens — instantly connecting to multimodal AI models (**Google Gemini**, OpenAI, Claude, or local on-device models) with animated iridescent glowing shaders, haptic feedback, and spotlight focus.

---

## ✨ Features

- 📷 **Live Camera Stream Integration**: Seamlessly overlays on top of `CameraPreview` for real-time visual inspection in physical space.
- 🎯 **Tap-to-Inspect Reticle**: Tap any object to summon an animated expanding target reticle that automatically frames the subject.
- ➰ **Freehand Lasso Selection**: Draw organic loops and circles around objects, text blocks, or diagrams with smooth Bezier interpolation.
- 🔲 **Adjustable Bounding Box**: Interactive drag-to-select with 4 corner touch handles for pixel-precision crops.
- 🌈 **Apple Visual Intelligence Neon Glow**: Animated, iridescent sweep-gradient shaders that illuminate and breathe around selected objects.
- 🔦 **Spotlight Focus Dimming**: Automatically dims the unselected viewport area to highlight the region of interest.
- ✂️ **Automatic RepaintBoundary Visual Cropping**: Captures the exact screen region from any widget tree or camera frame without manual coordinate math.
- 🤖 **Zero-Setup AI Connectors**:
  - **`MockVisionAdapter`**: 100% offline, instant mock responses for local development and testing with **zero API keys and zero cost**!
  - **`GeminiVisionAdapter`**: Plug in your Google Gemini API key to run real-time multimodal intelligence (`gemini-3.5-flash-lite`, `gemini-3.5-flash`).
  - **Custom AI Adapter**: Connect easily to OpenAI Vision, Claude, Ollama, or local TFLite / ONNX models.
- 📐 **Coordinate Mapping Engine**: Seamlessly maps screen coordinates through `BoxFit.contain`, `cover`, and letterboxed aspect ratios back to original image pixel coordinates.
- 🚀 **100% Multi-Platform**: Pure Flutter and Dart with zero native dependencies. Runs out of the box on **iOS, Android, Web, macOS, Windows, and Linux**.

---

## 📦 Installation

Add `flutter_vision_lens` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_vision_lens: ^0.1.0
```

Or run:

```bash
flutter pub add flutter_vision_lens
```

---

## 🚀 Quick Start: Live Camera Lens

Wrap your `CameraPreview` or `Image` with `VisionLensOverlay`:

```dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';

class LiveCameraLensScreen extends StatefulWidget {
  final CameraDescription camera;
  const LiveCameraLensScreen({super.key, required this.camera});

  @override
  State<LiveCameraLensScreen> createState() => _LiveCameraLensScreenState();
}

class _LiveCameraLensScreenState extends State<LiveCameraLensScreen> {
  late final CameraController _cameraController;
  late final VisionLensController _visionController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _visionController = VisionLensController(
      style: VisionLensStyle.appleIntelligence(),
    );

    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _cameraController.initialize().then((_) {
      if (mounted) setState(() => _isReady = true);
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _visionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: VisionLensOverlay(
        controller: _visionController,
        // Use MockVisionAdapter for instant offline testing without any keys!
        adapter: const MockVisionAdapter(),
        // Or connect to Google Gemini Multimodal AI:
        // adapter: GeminiVisionAdapter(apiKey: 'YOUR_GEMINI_API_KEY'),
        child: CameraPreview(_cameraController),
      ),
    );
  }
}
```

---

## 🤖 Connecting Real Google Gemini AI (Free Tier)

Google offers a generous free tier for Gemini at [Google AI Studio](https://aistudio.google.com). To use live multimodal AI:

```dart
VisionLensOverlay(
  controller: _controller,
  adapter: GeminiVisionAdapter(
    apiKey: 'YOUR_GEMINI_API_KEY',
    modelName: 'gemini-3.5-flash-lite', // High-speed, multimodal
  ),
  child: CameraPreview(cameraController),
)
```

---

## 📱 Permissions Setup (For Real Camera)

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed for real-time visual intelligence and object scanning.</string>
```

---

## 🎨 Visual Themes & Presets

Customize the glow colors, stroke widths, corner radii, and spotlight intensity:

```dart
// Apple Visual Intelligence style (Iridescent neon sweep gradient)
VisionLensStyle.appleIntelligence();

// Google Lens style (Clean material accents)
VisionLensStyle.googleLens();

// Cyberpunk Neon style (High-contrast cyan & hot pink)
VisionLensStyle.cyberpunk();

// Or create your own custom theme:
const VisionLensStyle(
  primaryColor: Color(0xFF00E5FF),
  borderWidth: 3.0,
  spotlightDimOpacity: 0.50,
  enableGlowAnimation: true,
);
```

---

## 🎯 Pre-Detected Objects (YOLO / Google ML Kit)

If your app already detects objects (e.g. from Google ML Kit or YOLO), you can feed them directly into the controller to display glowing candidate brackets:

```dart
_controller.setDetectedObjects([
  const VisionObject(
    id: 'item_1',
    label: 'Smart Watch',
    confidence: 0.98,
    normalizedRect: Rect.fromLTWH(0.2, 0.3, 0.4, 0.3),
  ),
]);
```

Tapping on any candidate bracket automatically locks focus onto that object!

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
