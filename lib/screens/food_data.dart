import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/services/generate_response.dart';
import 'package:hungryowl/services/llm_calls.dart';
import 'package:hungryowl/services/utils.dart';
import 'package:hungryowl/types/internal_types.dart';
import 'package:hungryowl/widgets/food_data/ingredient_list.dart';
import 'package:hungryowl/widgets/food_data/risk_score_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class FoodData extends ConsumerStatefulWidget {
  final String? imagePath;
  final String? foodName;

  const FoodData({
    super.key,
    this.imagePath,
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
    _foodData = _initFoodData();
  }

  Future<FoodSymptomInfo> _initFoodData() async {
    return await _identifyRiskAndRelation(
        widget.foodName ?? await _identifyFood());
  }

  Future<String> _identifyFood() async {
    var data = await transcribeFoodImage(dotenv.env['TEST_IMAGE']!);

    return data.name;
  }

  Future<FoodSymptomInfo> _identifyRiskAndRelation(String foodName) async {
    final user = ref.read(usersProvider).value;
    final symptomList = user?.symptoms ?? [];
    final response = await generateContent(foodName, symptomList.join(', '));
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
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ],
              ),
              body: Center(child: Text('Error: ${snapshot.error}')),
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
