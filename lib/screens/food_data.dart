import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:scan_app/services/llm_calls.dart';

class FoodData extends StatefulWidget {
  final String? imagePath;
  final String? foodName;

  const FoodData({
    super.key,
    this.imagePath,
    this.foodName,
  });

  @override
  State<FoodData> createState() => _FoodDataState();
}

class _FoodDataState extends State<FoodData> {
  late Future<Map<String, dynamic>> _foodData;
  String? _geminiSummary;
  late String foodName;
  List<String> symptoms = ["constipation", "bloating", "headache"];

  @override
  void initState() {
    super.initState();
    _foodData = _initFoodData();
  }

  Future<Map<String, dynamic>> _initFoodData() async {
    final name = widget.foodName ?? await _identifyFood();

    setState(() {
      foodName = name;
    });

    return await _identifyTriggers();
  }

  Future<String> _identifyFood() async {
    var data = await transcribeFoodImage(dotenv.env['TEST_IMAGE']!);

    setState(() {
      foodName = data.name;
    });

    return data.name;
  }

  Future<Map<String, dynamic>> _identifyTriggers() async {
    final symptomsString = symptoms.join(', ');
    final prompt = '''
Analyze how $foodName could be related to the following symptoms: $symptomsString.
Give a brief summary of how this food might impact someone's health, considering these symptoms.
''';

    try {
      final model = GenerativeModel(
        model: 'models/gemini-2.0-flash',
        apiKey: dotenv.env['GEMINI_API_KEY']!,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _geminiSummary = response.text?.trim() ?? 'No summary generated.';
      });
    } catch (e) {
      print("Error generating summary: $e");
      setState(() {
        _geminiSummary = 'Error generating summary.';
      });
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _foodData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return SingleChildScrollView(
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
                  if (_geminiSummary != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        _geminiSummary!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
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
