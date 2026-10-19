import '../models/vision_region.dart';

/// Base contract for AI adapters that accept vision regions and return intelligence insights.
abstract class VisionAiAdapter {
  /// Analyzes the targeted [region] using the provided [prompt] directive.
  Future<String> analyze({
    required VisionRegion region,
    required String prompt,
  });

  /// Common visual prompt preset to explain an object or diagram.
  static const String promptExplain =
      'Analyze the selected region. Identify what this is, its purpose, and provide a clear, concise breakdown.';

  /// Common visual prompt preset to extract text (OCR) and structured numbers.
  static const String promptOCR =
      'Extract and format all visible text, numbers, prices, or codes from this selected region.';

  /// Common visual prompt preset to translate visible text.
  static String promptTranslate({String targetLanguage = 'English'}) =>
      'Translate all visible text in this selected area into $targetLanguage. Provide phonetic pronunciation if applicable.';

  /// Common visual prompt preset to solve a math, logic, or science problem.
  static const String promptSolve =
      'Read the math, code, or science problem in this region and provide a clear step-by-step solution.';
}
