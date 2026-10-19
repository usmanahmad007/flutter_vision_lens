import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vision_region.dart';
import 'vision_ai_adapter.dart';

/// Multimodal AI adapter connecting the vision lens directly to the Google Gemini API.
class GeminiVisionAdapter implements VisionAiAdapter {
  /// The Google Gemini API key obtained from Google AI Studio.
  final String apiKey;

  /// The Gemini model name (defaults to 'gemini-3.5-flash-lite').
  final String modelName;

  /// Custom or mocked HTTP client for testing.
  final http.Client _client;

  /// Creates a [GeminiVisionAdapter].
  GeminiVisionAdapter({
    required this.apiKey,
    this.modelName = 'gemini-3.5-flash-lite',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<String> analyze({
    required VisionRegion region,
    required String prompt,
  }) async {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/interactions');

    final inputList = <Map<String, dynamic>>[];

    // Add inline image payload if byte data was captured
    if (region.imageBytes != null && region.imageBytes!.isNotEmpty) {
      final bytes = region.imageBytes!;
      final isPng = bytes.length > 4 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47;
      final mimeType = isPng ? 'image/png' : 'image/jpeg';
      final base64Image = base64Encode(bytes);
      inputList.add({
        'type': 'image',
        'data': base64Image,
        'mime_type': mimeType,
      });
    }

    // Add user prompt text
    inputList.add({
      'type': 'text',
      'text': prompt,
    });

    final requestBody = jsonEncode({
      'model': modelName,
      'input': inputList,
    });

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // 1. Try modern Interactions steps output
        final steps = data['steps'] as List<dynamic>?;
        if (steps != null) {
          for (final step in steps) {
            if (step is Map<String, dynamic> && step['type'] == 'model_output') {
              final content = step['content'] as List<dynamic>?;
              if (content != null && content.isNotEmpty) {
                final textItem = content.firstWhere(
                  (c) => c is Map<String, dynamic> && c['type'] == 'text',
                  orElse: () => null,
                );
                if (textItem != null) {
                  return textItem['text'] as String;
                }
              }
            }
          }
        }

        // 2. Fallback to outputs list
        final outputs = data['outputs'] as List<dynamic>?;
        if (outputs != null && outputs.isNotEmpty) {
          final firstText = outputs.firstWhere(
            (o) => o is Map<String, dynamic> && o['type'] == 'text',
            orElse: () => null,
          );
          if (firstText != null) {
            return firstText['text'] as String;
          }
        }

        // 3. Fallback to legacy candidates if applicable
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final first = candidates.first as Map<String, dynamic>;
          final parts = first['content']?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            return parts.first['text'] as String? ?? 'No response text.';
          }
        }

        return 'Received response without text output.';
      } else {
        return 'Gemini API Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      return 'Failed to communicate with Gemini API: $e';
    }
  }
}
