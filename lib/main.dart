import 'package:flutter/material.dart';
import 'package:scan_app/screens/food_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScanPage(),
    );
  }
}

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodData()),
            );
          },
          child: const Text('Take Picture'),
        ),
      ),
    );
  }
}
