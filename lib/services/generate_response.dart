/*
  You'll need a Firebase project and the `firebase-ai` dependency to run this code.
  Learn how to set up your environment: https://firebase.google.com/docs/ai-logic/get-started
 */

import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_ai/firebase_ai.dart';
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
    String? food, Uint8List? imageBytes, String symptomList) async {
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
    TextPart('''
You are a food–symptom component analyzer. You will be given one of the following for a food: 

1. A food name (string)
2. A picture of a food
3. A picture of an ingredient list

You will also be given a list of symptoms (array of strings). 

Instructions:

- **If given a food name**, analyze the food directly.
- **If given a picture of a food**, identify the food as specifically as possible, including brand and flavors if applicable. If you cannot identify it, return "unknown" as the food name.
- **If given a picture of an ingredient list**, generate a generic food name if the specific food is unknown.

**Symptom List**: $symptomList

Your task is to:

1. Break the food into its nutrients, phytochemicals, bioactive compounds, and naturally occurring amines or acids (e.g., tyramine, histamine), but **only include compounds with well-documented, clinically significant links to at least one of the listed symptoms**.
2. Exclude: allergies, rare or anecdotal associations, and any compound that requires phrasing like "in sensitive individuals" or "in rare cases".
3. For each relevant compound:
   - Assign a risk score (1–10) **for each symptom**, based only on known, direct physiological or chemical links.
   - Provide concise reasoning for that score, framed for individuals with a prior history of the symptom (not the general population).
4. If no compounds are relevant, return an empty list for `relevantCompounds` and set the `overallRiskScore` to 1 with the explanation: 
   "This food does not contain any known compounds linked to the listed symptoms."
5. Assign an overall risk score (1–10) to the food as a whole with a brief explanation of its likely impact on individuals with the listed symptoms.

**English only.**
'''),
    if (imageBytes != null) InlineDataPart('image/png', imageBytes),
    if (imageBytes == null) TextPart('Food: $food'),
  ]);

  final chat = model.startChat();

  final response = await chat.sendMessage(message);

  final jsonString = response.text;
  final Map<String, dynamic> jsonResponse = jsonDecode(jsonString!);

  return FoodSymptomInfo.fromJson(jsonResponse);
}
