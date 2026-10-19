import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_vision_lens/flutter_vision_lens.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('VisionAiAdapter Tests', () {
    final testRegion = VisionRegion(
      normalizedRect: const Rect.fromLTWH(0.1, 0.1, 0.4, 0.4),
      screenRect: const Rect.fromLTWH(50, 50, 200, 200),
      viewportSize: const Size(500, 500),
    );

    test('MockVisionAdapter returns simulated OCR results', () async {
      const adapter = MockVisionAdapter(simulatedDelay: Duration.zero);

      final result = await adapter.analyze(
        region: testRegion,
        prompt: VisionAiAdapter.promptOCR,
      );

      expect(result, contains('Extracted Text (OCR)'));
      expect(result, contains('Flutter Vision Lens'));
    });

    test('MockVisionAdapter returns translation results', () async {
      const adapter = MockVisionAdapter(simulatedDelay: Duration.zero);

      final result = await adapter.analyze(
        region: testRegion,
        prompt: VisionAiAdapter.promptTranslate(targetLanguage: 'Spanish'),
      );

      expect(result, contains('Translation Result'));
    });

    test('MockVisionAdapter returns math solve results', () async {
      const adapter = MockVisionAdapter(simulatedDelay: Duration.zero);

      final result = await adapter.analyze(
        region: testRegion,
        prompt: VisionAiAdapter.promptSolve,
      );

      expect(result, contains('Step-by-Step Solution'));
      expect(result, contains('x = 10'));
    });

    test('MockVisionAdapter respects fixedResponse override', () async {
      const adapter = MockVisionAdapter(
        simulatedDelay: Duration.zero,
        fixedResponse: 'Custom Fixed Output',
      );

      final result = await adapter.analyze(
        region: testRegion,
        prompt: 'any prompt',
      );

      expect(result, 'Custom Fixed Output');
    });

    test('GeminiVisionAdapter handles successful API response', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), contains('generativelanguage.googleapis.com'));
        expect(request.headers['x-goog-api-key'], 'test_gemini_key');

        final fakeGeminiResponse = {
          'steps': [
            {
              'type': 'model_output',
              'content': [
                {'type': 'text', 'text': 'Gemini Identified: Vintage Wristwatch'},
              ],
            },
          ],
        };

        return http.Response(
          jsonEncode(fakeGeminiResponse),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final adapter = GeminiVisionAdapter(
        apiKey: 'test_gemini_key',
        client: mockClient,
      );

      final output = await adapter.analyze(
        region: testRegion,
        prompt: 'What watch is this?',
      );

      expect(output, 'Gemini Identified: Vintage Wristwatch');
    });

    test('GeminiVisionAdapter formats error when API responds with error code', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Invalid API Key', 403);
      });

      final adapter = GeminiVisionAdapter(
        apiKey: 'bad_key',
        client: mockClient,
      );

      final output = await adapter.analyze(
        region: testRegion,
        prompt: 'test prompt',
      );

      expect(output, contains('Gemini API Error (403)'));
    });
  });
}
