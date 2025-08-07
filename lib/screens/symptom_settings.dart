import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_app/models/users.dart';

class SymptomSettings extends ConsumerStatefulWidget {
  const SymptomSettings({super.key});

  @override
  ConsumerState<SymptomSettings> createState() => _SymptomSettings();
}

class _SymptomSettings extends ConsumerState<SymptomSettings> {
  final _symptomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currUser = ref.read(usersProvider).value;
      if (currUser != null) {
        _symptomsController.text = currUser.symptoms.join(', ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _symptomsController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                labelText: 'Symptoms',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                hintText: 'Enter symptoms separated by commas...',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final symptomsText = _symptomsController.text.trim();
                try {
                  await updateUser(updatedData: {
                    'symptoms':
                        symptomsText.split(',').map((s) => s.trim()).toList(),
                  });
                } catch (e) {
                  debugPrint("Failed to update symptoms");
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
