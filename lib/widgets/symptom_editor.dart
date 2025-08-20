import 'package:flutter/material.dart';

class SymptomEditor extends StatefulWidget {
  final List<String> initialSymptoms;
  final Function(List<String>) onSymptomsChanged;
  final bool isOnboarding;

  const SymptomEditor({
    super.key,
    required this.initialSymptoms,
    required this.onSymptomsChanged,
    this.isOnboarding = false,
  });

  @override
  SymptomEditorState createState() => SymptomEditorState();
}

class SymptomEditorState extends State<SymptomEditor> {
  final _symptomController = TextEditingController();
  late List<String> _symptoms;

  @override
  void initState() {
    super.initState();
    _symptoms = widget.initialSymptoms;
  }

  void _addSymptom() {
    final symptom = _symptomController.text.trim();
    if (symptom.isNotEmpty && !_symptoms.contains(symptom)) {
      final newSymptoms = [..._symptoms, symptom];
      setState(() {
        _symptoms = newSymptoms;
        _symptomController.clear();
      });
      widget.onSymptomsChanged(newSymptoms);
    }
    FocusScope.of(context).unfocus();
  }

  void _removeSymptom(String symptom) {
    final newSymptoms = _symptoms.where((s) => s != symptom).toList();
    setState(() {
      _symptoms = newSymptoms;
    });
    widget.onSymptomsChanged(newSymptoms);
  }

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                maxLines: null,
                minLines: 1,
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
        const SizedBox(height: 5,),
        Text(
            "You can also add conditions and diseases (IBS, Celiac Disease, Migraines, etc.)"),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _symptoms.map((symptom) {
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        symptom,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeSymptom(symptom),
                      child: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
