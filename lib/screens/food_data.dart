import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/services/generate_response.dart';
import 'package:hungryowl/services/llm_calls.dart';
import 'package:hungryowl/services/utils.dart';
import 'package:hungryowl/types/internal_types.dart';

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
  late Future<FoodCorrelationResponse> _foodData;
  late String foodName;

  @override
  void initState() {
    super.initState();
    _foodData = _initFoodData();
  }

  Future<FoodCorrelationResponse> _initFoodData() async {
    final name = widget.foodName ?? await _identifyFood();

    setState(() {
      foodName = name;
    });

    return await _identifyTriggers();
  }

  Future<String> _identifyFood() async {
    var data = await transcribeFoodImage(dotenv.env['TEST_IMAGE']!);

    return data.name;
  }

  Future<FoodCorrelationResponse> _identifyTriggers() async {
    final user = ref.read(usersProvider).value;
    final symptomsList = user?.symptoms ?? [];
    final symptomList = symptomsList.join(', ');
    final response = await generateContent(foodName, symptomList);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: FutureBuilder<FoodCorrelationResponse>(
        future: _foodData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final foodData = snapshot.data!;
            final symptomInfo = foodData.symptoms;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      capitalizedTitle(foodName),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  symptomInfo.isNotEmpty
                      ? Column(
                          children: symptomInfo
                              .where((symptom) =>
                                  symptom.potentialCorrelations.isNotEmpty)
                              .map((symptom) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${isValidSingleEmoji(symptom.emoji) ? symptom.emoji : '🤨'} ${capitalizedTitle(symptom.symptom)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 8.0),
                                    ...symptom.potentialCorrelations
                                        .map((correlation) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, bottom: 5),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "• ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Expanded(
                                              child: Text(
                                                correlation,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No relevant symptom correlations found.',
                        ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
