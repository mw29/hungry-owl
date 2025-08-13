import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/services/generate_response.dart';
import 'package:hungryowl/services/llm_calls.dart';
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
        elevation: 0,
        automaticallyImplyLeading: false,
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
            final foodName = foodData.foodName;
            final symptomInfo = foodData.symptoms;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      foodName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: symptomInfo.isNotEmpty
                        ? ListView.builder(
                            itemCount: symptomInfo.length,
                            itemBuilder: (context, index) {
                              final symptom = symptomInfo[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      symptom.symptom,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...symptom.potentialCorrelations
                                        .map((correlation) {
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "• ",
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              correlation,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black87,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              );
                            },
                          )
                        : const Text(
                            'No relevant symptom correlations found.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
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
