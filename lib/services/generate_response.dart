/*
  You'll need a Firebase project and the `firebase-ai` dependency to run this code.
  Learn how to set up your environment: https://firebase.google.com/docs/ai-logic/get-started
 */

import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:hungryowl/services/utils.dart';
import 'package:hungryowl/types/internal_types.dart';

final ingredientJsonSchema = Schema.object(
  properties: {
    'foodName': Schema.string(
      description: 'Name of the food being analyzed.',
    ),
    'foodEmoji': Schema.string(
      description: 'One emoji that best represents the food.',
    ),
    'overallRiskScore': Schema.integer(
      description:
          'Overall risk score for the food (higher means more likely to cause symptoms).',
    ),
    'overview': Schema.string(
      description:
          'Brief summary of the food’s potential effects for someone with relevant sensitivities.',
    ),
    'relevantIngredients': Schema.array(
      description:
          'List of ingredients in the food that may be relevant to symptoms.',
      items: Schema.object(
        properties: {
          'ingredientName': Schema.string(
            description: 'Name of the ingredient.',
          ),
          'emoji': Schema.string(
            description: 'One emoji that best represents the ingredient.',
          ),
          'relatedSymptoms': Schema.array(
            description: 'List of symptoms associated with this ingredient.',
            items: Schema.object(
              properties: {
                'symptomName': Schema.string(
                  description: 'Name of the symptom.',
                ),
                'symptomRiskScore': Schema.integer(
                  description:
                      'Risk score for this symptom from this ingredient.',
                ),
                'information': Schema.array(
                  description:
                      'List of explanations for how the ingredient could be linked to this symptom.',
                  items: Schema.string(),
                ),
              },
            ),
          ),
        },
      ),
    ),
  },
);

Future<FoodSymptomInfo> generateAnalysisContent(
    String foodName, String symptomList) async {
  final generationConfig = GenerationConfig(
    temperature: 0,
    responseSchema: ingredientJsonSchema,
    responseMimeType: 'application/json',
  );

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: generationConfig,
  );
  final message = Content('user', [
    TextPart(
        'You are a symptom/ingredient analyzer. You will be given a food and a list of symptoms. You will dissect the food into ingredients and for each ingredient give a risk score (how likely the ingredient is to cause the symptom for individuals with a history of the symptom) for each symptom from 1-10 and explain why you gave it that score as 1-3 short bullet points in the information field. Through out any ingredients that could not plausibly cause the symptoms, no antidotal evidence, hypotheticals, or indirect links. Assign one single emoji where asked. Food: $foodName, Symptoms: $symptomList'),
    TextPart('INSERT_INPUT_HERE'),
  ]);

  final chat = model.startChat();

  final response = await chat.sendMessage(message);

  final jsonString = response.text;
  final Map<String, dynamic> jsonResponse = jsonDecode(jsonString!);

  return FoodSymptomInfo.fromJson(jsonResponse);
}

final foodNameJsonSchema = Schema.object(properties: {
  'foodName': Schema.string(
      description: 'Most accurate name for the food shown in the picture or unknown if unidentifiable'),
});

Future<String> generateFoodContent(String path) async {
  final imageBytes = await imagePathToBytes(path);

  final generationConfig = GenerationConfig(
    temperature: 0,
    responseSchema: foodNameJsonSchema,
    responseMimeType: 'application/json',
  );

  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.0-flash',
    generationConfig: generationConfig,
  );

  final chat = model.startChat();

  final message = Content('user', [
    InlineDataPart('image/png', imageBytes),
    TextPart(
        'Please identify the food shown in this image. Be specific: include brand and flavors if applicable. Return unknown as food name if you cannot successfully identify the food.'),
  ]);

  final response = await chat.sendMessage(message);

  final jsonString = response.text;

  final Map<String, dynamic> jsonResponse = jsonDecode(jsonString!);
  return jsonResponse['foodName'];
}
