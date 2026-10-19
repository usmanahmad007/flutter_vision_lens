import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vision_region.dart';
import 'vision_ai_adapter.dart';

/// Multimodal AI adapter connecting the vision lens directly to the Google Gemini API.
class GeminiVisionAdapter implements VisionAiAdapter {
  /// The Google Gemini API key obtained from Google AI Studio.
  final String apiKey;

  /// The Gemini model name (defaults to 'gemini-1.5-flash').
  final String modelName;

  /// Custom or mocked HTTP client for testing.
  final http.Client _client;

  /// Creates a [GeminiVisionAdapter].
  GeminiVisionAdapter({
    required this.apiKey,
    this.modelName = 'gemini-1.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> analyze({
    required VisionRegion region,
    required String prompt,
  }) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey',
    );

    final parts = <Map<String, dynamic>>[];

    // Add visual prompt text
    parts.add({'text': prompt});

    // Add inline image payload if byte data was captured
    if (region.imageBytes != null && region.imageBytes!.isNotEmpty) {
      final base64Image = base64Encode(region.imageBytes!);
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        },
      });
    }

    final requestBody = jsonEncode({
      'contents': [
        {'parts': parts},
      ],
    });

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final firstCandidate = candidates.first as Map<String, dynamic>;
          final content = firstCandidate['content'] as Map<String, dynamic>?;
          final responseParts = content?['parts'] as List<dynamic>?;
          if (responseParts != null && responseParts.isNotEmpty) {
            final firstPart = responseParts.first as Map<String, dynamic>;
            return firstPart['text'] as String? ?? 'No response text received.';
          }
        }
        return 'No intelligence candidates returned.';
      } else {
        return 'Gemini API Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      return 'Failed to communicate with Gemini API: $e';
    }
  }
}
