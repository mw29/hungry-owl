import 'package:flutter/material.dart';
import 'package:hungryowl/screens/food_data.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  ManualEntryScreenState createState() => ManualEntryScreenState();
}

class ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _foodNameController = TextEditingController();
  bool _showButton = false;

  @override
  void dispose() {
    _foodNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
              ),
              onChanged: (text) {
                setState(() {
                  _showButton = text.isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 20),
            if (_showButton)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodData(
                        foodName: _foodNameController.text,
                      ),
                    ),
                  );
                },
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}
