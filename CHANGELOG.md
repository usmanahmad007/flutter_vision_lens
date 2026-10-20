## 0.1.0

* **Initial release of `flutter_vision_lens`** — Interactive Apple Visual Intelligence and Google Lens style multimodal vision overlay for Flutter.
* **Live Camera Stream Integration**: First-class support for `CameraPreview` with seamless overlay rendering.
* **Selection Modes**:
  * Tap-to-Inspect with animated expanding reticle and candidate brackets.
  * Freehand Lasso selection with organic Bezier contouring.
  * Interactive 4-corner adjustable bounding box.
* **Apple Visual Intelligence Shaders**:
  * Iridescent neon shimmering sweep-gradient border glow.
  * Smooth animated spotlight focus and dimmed background shader.
* **Automatic Visual Cropping Engine**:
  * Precision pixel cropping using `RepaintBoundary` directly from any widget or camera frame.
  * Aspect ratio and letterbox mapping for `BoxFit.contain` and `BoxFit.cover`.
* **Multimodal AI Adapters**:
  * `MockVisionAdapter` for 100% offline development with simulated OCR, translation, math solving, and visual descriptions.
  * `GeminiVisionAdapter` connecting to Google Gemini Interactions API (`gemini-3.5-flash-lite`, `gemini-3.5-flash`) with automatic base64 visual payload.
  * Extensible `VisionAiAdapter` base class for custom models (OpenAI, Claude, Ollama, ONNX).
* **Interactive UI Components**:
  * `VisionLensToolbar` with mode switcher, haptic feedback, and camera controls.
  * `VisionLensResultSheet` modern floating response card with action buttons, confidence scores, and OCR text extraction.
* **Complete Example Application**:
  * Hardware camera stream with front/back camera flipping and flash torch.
  * Photo gallery picker and interactive simulation mode.
  * In-app secure Gemini API key dialog.
* **Cross-Platform**: Android, iOS, Web, macOS, Windows, Linux.
