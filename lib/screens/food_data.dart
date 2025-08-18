import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/screens/manual_entry.dart';
import 'package:hungryowl/services/generate_response.dart';
import 'package:hungryowl/services/utils.dart';
import 'package:hungryowl/types/internal_types.dart';
import 'package:hungryowl/widgets/food_data/ingredient_list.dart';
import 'package:hungryowl/widgets/food_data/risk_score_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodData extends ConsumerStatefulWidget {
  final Uint8List? imageBytes;
  final String? foodName;

  const FoodData({
    super.key,
    this.imageBytes,
    this.foodName,
  });

  @override
  ConsumerState<FoodData> createState() => _FoodData();
}

class _FoodData extends ConsumerState<FoodData> {
  late Future<FoodSymptomInfo> _foodData;
  late String foodName;

  @override
  void initState() {
    super.initState();
    _foodData = _identifyRiskAndRelation();
  }

  Future<FoodSymptomInfo> _identifyRiskAndRelation() async {
    final user = ref.read(usersProvider).value;
    final symptomList = user?.symptoms ?? [];
    final response = await generateAnalysisContent(
        widget.foodName, widget.imageBytes, symptomList.join(', '));
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FoodSymptomInfo>(
        future: _foodData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to identify food!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'This can happen if the image is blurry, the food is too complex, or it wasn’t clear in the picture.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retake Picture'),
                      ),
                      const SizedBox(height: 12),
                      const Text("or"),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManualEntryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Enter Food Manually'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final foodData = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                title: Text(
                    '${isValidSingleEmoji(foodData.foodEmoji) ? foodData.foodEmoji : '🍽️'} ${capitalizedTitle(foodData.foodName)}'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Overview',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('About This Data'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Medical Disclaimer',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const Text(
                                            'This is not intended as medical advice. AI can make mistakes. Always consult with a qualified healthcare professional before making any health-related decisions.'),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'Sources',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const Text(
                                            'Below is a comprehensive list of citations and resources to help you explore your personal ingredient analysis in greater detail.'),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        const Text(
                                          "Digestive Disfunction",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () => launchUrl(Uri.parse(
                                              'https://www.nutrition.gov/topics/diet-and-health-conditions/digestive-disorders')),
                                          child: const Text(
                                            'Read about digestive disorders and disfunction',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Diet and Sleep",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () => launchUrl(Uri.parse(
                                              'https://pubmed.ncbi.nlm.nih.gov/33549913/')),
                                          child: const Text(
                                            'Read about the correlation between diet and sleep',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "General Nutrition",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () => launchUrl(Uri.parse(
                                              'https://nutrition.org/')),
                                          child: const Text(
                                            'Visit the American Society for Nutrition',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      RiskScoreBar(
                        score: foodData.overallRiskScore,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(foodData.overview),
                      if (foodData.relevantIngredients.isNotEmpty) ...[
                        SizedBox(
                          height: 12,
                        ),
                        Text(
                          "Relevant Ingredients",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        IngredientsListView(
                          ingredients: foodData.relevantIngredients,
                        )
                      ]
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('No data available'));
        });
  }
}
