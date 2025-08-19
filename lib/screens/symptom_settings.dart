import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/widgets/symptom_editor.dart';

class SymptomSettings extends ConsumerStatefulWidget {
  const SymptomSettings({super.key});

  @override
  ConsumerState<SymptomSettings> createState() => _SymptomSettings();
}

class _SymptomSettings extends ConsumerState<SymptomSettings> {
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

  void _updateSymptoms(List<String> newSymptoms) {
    if (newSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must have at least one symptom."),
        ),
      );
      return;
    }
    setState(() {
      _symptoms = newSymptoms;
    });
    updateUser(updatedData: {'symptoms': newSymptoms});
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
      appBar: AppBar(
        title: const Text('Symptoms'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
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
              SymptomEditor(
                initialSymptoms: _symptoms,
                onSymptomsChanged: _updateSymptoms,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
