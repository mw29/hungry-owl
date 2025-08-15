import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';

class SymptomSettings extends ConsumerStatefulWidget {
  const SymptomSettings({super.key});

  @override
  ConsumerState<SymptomSettings> createState() => _SymptomSettings();
}

class _SymptomSettings extends ConsumerState<SymptomSettings> {
  final _symptomController = TextEditingController();
  List<String> _symptoms = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(usersProvider).value;
    if (user != null) {
      _initializeSymptoms(user.symptoms);
    }
  }

  void _initializeSymptoms(List<String> symptoms) {
    setState(() {
      _symptoms = symptoms;
    });
  }

  void _addSymptom() {
    final symptom = _symptomController.text.trim();
    if (symptom.isNotEmpty && !_symptoms.contains(symptom)) {
      final newSymptoms = [..._symptoms, symptom];
      setState(() {
        _symptoms = newSymptoms;
        _symptomController.clear();
      });
      updateUser(updatedData: {'symptoms': newSymptoms});
    }
  }

  void _removeSymptom(String symptom) {
    final newSymptoms = _symptoms.where((s) => s != symptom).toList();
    setState(() {
      _symptoms = newSymptoms;
    });
    updateUser(updatedData: {'symptoms': newSymptoms});
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(usersProvider, (previous, next) {
      if (!mounted) return;
      final user = next.value;
      if (user != null) {
        _initializeSymptoms(user.symptoms);
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'What are your symptoms?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'These symptoms will be used in ingredient analysis when you scan or add a food.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _symptomController,
                    decoration: const InputDecoration(
                      labelText: 'Symptom',
                      border: OutlineInputBorder(),
                      hintText: 'Enter a symptom',
                    ),
                    onSubmitted: (_) => _addSymptom(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSymptom,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _symptoms
                  .map((symptom) => Chip(
                        label: Text(symptom),
                        onDeleted: () => _removeSymptom(symptom),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
