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
                    '${isValidSingleEmoji(foodData.foodEmoji) ? foodData.foodEmoji : '🍽️'} ${foodData.foodName}'),
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
                padding: const EdgeInsets.all(16.0),
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
                          Icon(Icons.info), // TODO CHANGE THIS INTO A POPUP
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
