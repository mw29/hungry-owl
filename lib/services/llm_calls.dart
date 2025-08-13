import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hungryowl/types/internal_types.dart';

Future<Map<String, dynamic>> _getLLMResponse({
  required Map<String, dynamic> input,
  required String promptName,
  required String promptVersion,
  int maxAttempts = 3,
  int timeoutSeconds = 16,
}) async {
  int attempt = 0;
  while (attempt < maxAttempts) {
    try {
      final requestBody = json.encode({
        'input': input,
        'prompt_name': promptName,
        'prompt_version': promptVersion
      });

      debugPrint('LLM Request Body: $requestBody');

      final response = await http
          .post(
            Uri.parse(dotenv.env['STASHGPT_ADDRESS']!),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'uid': dotenv.env['TEST_UID']!,
            },
            body: requestBody,
          )
          .timeout(Duration(seconds: timeoutSeconds));

      debugPrint('LLM Response Status Code: ${response.statusCode}');
      debugPrint('LLM Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData =
            json.decode(response.body)['response'];
        return responseData;
      } else {
        throw Exception('Failed to load LLM response: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _getLLMResponse: $e');
      attempt++;
      if (attempt >= maxAttempts) {
        throw Exception('Failed after $maxAttempts attempts: $e');
      }
      timeoutSeconds = (timeoutSeconds * 2).clamp(0, 32);

      debugPrint(
          'Attempt $attempt failed. Retrying in $timeoutSeconds seconds...');
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  throw Exception('Unexpected error in retry logic');
}

Future<FoodIdResponseData> transcribeFoodImage(String url) async {
  Map<String, dynamic> responseData = await _getLLMResponse(
      input: {
        'prompt_images': [url]
      },
      promptName: dotenv.env['PROMPT_NAME']!,
      promptVersion: dotenv.env['PROMPT_VERSION']!);

  return FoodIdResponseData.fromJson(responseData);
}
