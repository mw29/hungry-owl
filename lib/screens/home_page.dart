import 'package:flutter/material.dart';
import 'package:scan_app/screens/food_data.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodData()),
            );
          },
          child: const Text('Scan Food'),
        ),
      ),
    );
  }
}
