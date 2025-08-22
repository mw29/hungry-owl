import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

final schema =
    Schema.object(properties: {'isValidSymptomOrCondition': Schema.boolean()});

Future<bool> checkSymptomValidity(String symptom) async {
  try {
    final generationConfig = GenerationConfig(
      responseSchema: schema,
      responseMimeType: 'application/json',
    );

    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-1.5-flash-8b',
      generationConfig: generationConfig,
    );

    final message = Content('user', [
      TextPart('Is "$symptom" a valid symptom or medical condition/disease?'),
    ]);
    final chat = model.startChat();

    final response = await chat.sendMessage(message);
    final responseText = response.text;

    if (responseText != null) {
      final decodedResponse = jsonDecode(responseText);
      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('isValidSymptomOrCondition') &&
          decodedResponse['isValidSymptomOrCondition'] is bool) {
        return decodedResponse['isValidSymptomOrCondition'];
      }
    }
    return false;
  } catch (e) {
    print('Error checking symptom validity: $e');
    return false;
  }
}
