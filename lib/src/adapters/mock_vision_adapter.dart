import 'dart:async';
import '../models/vision_region.dart';
import 'vision_ai_adapter.dart';

/// An offline, zero-configuration mock adapter for local testing, offline previews,
/// and automated widget testing without needing any live API keys.
class MockVisionAdapter implements VisionAiAdapter {
  /// Artificial network latency simulation duration.
  final Duration simulatedDelay;

  /// Optional fixed response override.
  final String? fixedResponse;

  /// Creates a [MockVisionAdapter] with an optional simulated network delay.
  const MockVisionAdapter({
    this.simulatedDelay = const Duration(milliseconds: 700),
    this.fixedResponse,
  });

  @override
  Future<String> analyze({
    required VisionRegion region,
    required String prompt,
  }) async {
    if (simulatedDelay > Duration.zero) {
      await Future.delayed(simulatedDelay);
    }

    if (fixedResponse != null) {
      return fixedResponse!;
    }

    final lowerPrompt = prompt.toLowerCase();

    if (lowerPrompt.contains('ocr') || lowerPrompt.contains('extract')) {
      return '📄 **Extracted Text (OCR)**\n\n'
          '• **Title:** Flutter Vision Lens\n'
          '• **Version:** 0.1.0 (Production Release)\n'
          '• **Confidence:** 99.2%\n'
          '• **Payload:** #FL-VISION-2026';
    }

    if (lowerPrompt.contains('translate')) {
      return '🌐 **Translation Result**\n\n'
          '• **Detected Language:** French (fr)\n'
          '• **Translated Text:** "Welcome to the future of interactive on-device intelligence."\n'
          '• **Accuracy:** High';
    }

    if (lowerPrompt.contains('math') || lowerPrompt.contains('solve')) {
      return '📐 **Step-by-Step Solution**\n\n'
          '1. **Equation Identified:** 3x + 15 = 45\n'
          '2. Subtract 15 from both sides: 3x = 30\n'
          '3. Divide both sides by 3: **x = 10**\n'
          '✓ Verified correct.';
    }

    return '✨ **Visual Intelligence Insights**\n\n'
        '• **Object:** Smart Electronic Device / Peripheral\n'
        '• **Confidence:** 97.8%\n'
        '• **Details:** Features an interactive multi-touch display and precision optical sensors.\n'
        '• **Suggested Action:** Inspect product specifications or extract serial number.';
  }
}
