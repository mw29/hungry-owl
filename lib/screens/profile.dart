import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scan_app/models/users.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends ConsumerState<ProfileScreen> {
  final _symptomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currUser = ref.read(usersProvider).value;
      if (currUser != null) {
        _symptomsController.text = _formatSymptoms(currUser.symptoms);
      }
    });
  }

  String _formatSymptoms(dynamic symptoms) {
    if (symptoms is List<String>) {
      return symptoms.join(', ');
    } else if (symptoms is String) {
      return symptoms;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final symptomsText = _symptomsController.text.trim();
                try {
                  await updateUser(updatedData: {
                    'symptoms':
                        symptomsText.split(',').map((s) => s.trim()).toList(),
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User symptoms updated.')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed to update: ${e.toString()}')),
                  );
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
