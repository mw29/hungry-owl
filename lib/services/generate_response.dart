/*
  You'll need a Firebase project and the `firebase-ai` dependency to run this code.
  Learn how to set up your environment: https://firebase.google.com/docs/ai-logic/get-started
 */

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:hungryowl/types/internal_types.dart';

final jsonSchema = Schema.object(
  properties: {
    'foodName': Schema.string(
      description: 'Name of the food being analyzed.',
    ),
    'symptoms': Schema.array(
      items: Schema.object(
        properties: {
          'symptom': Schema.string(
            description: 'Name of the symptom or outcome being analyzed.',
          ),
          'emoji': Schema.string(
            description: 'One emoji that best represents the symptom.',
          ),
          'potentialCorrelation': Schema.array(
            items: Schema.string(
              description:
                  'Short explanation of how the food could realistically be correlated to this symptom.',
            ),
            description:
                'List of short explanations (1–3) describing realistic correlations between the food and the symptom. Empty if no realistic correlation exists.',
          ),
        },
      ),
    ),
  },
);

Future<FoodCorrelationResponse> generateContent(
    String foodName, String symptomList) async {
  final generationConfig = GenerationConfig(
    responseSchema: jsonSchema,
    responseMimeType: 'application/json',
  );

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: generationConfig,
  );
  final message = Content('user', [
    TextPart(
        'Analyze how the ingredients in $foodName could plausibly cause or worsen the following symptoms/outcomes: $symptomList. Only include symptoms if there is clear, strong, and scientifically supported evidence that $foodName could directly cause or exacerbate them. Exclude any symptom where the link is weak, indirect, anecdotal, or beneficial. One bullet point worth of text MAX! Assign an emoji that best represents the symptom name to emoji.'),
    TextPart('INSERT_INPUT_HERE'),
  ]);

  final chat = model.startChat();

  final response = await chat.sendMessage(message);

  final jsonString = response.text;
  final Map<String, dynamic> jsonResponse = jsonDecode(jsonString!);

  return FoodCorrelationResponse.fromJson(jsonResponse);
}
