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
  bool _hasSetInitialSymptoms = false;
  String _initialSymptoms = '';
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _symptomsController.addListener(() {
      if (!_hasSetInitialSymptoms) return;
      final current = _symptomsController.text.trim();
      setState(() {
        _hasChanges = current != _initialSymptoms;
      });
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
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(usersProvider);
    final currUser = userAsync.value;

    if (!_hasSetInitialSymptoms && currUser != null) {
      final formatted = _formatSymptoms(currUser.symptoms).trim();
      _symptomsController.text = formatted;
      _initialSymptoms = formatted;
      _hasSetInitialSymptoms = true;
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _symptomsController,
              maxLines: null,
              minLines: 3,
              decoration: const InputDecoration(
                labelText: 'Symptoms',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                hintText: 'Enter symptoms separated by commas...',
              ),
            ),
            const SizedBox(height: 20),
            if (_hasChanges)
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        final symptomsText = _symptomsController.text.trim();
                        setState(() => _isSaving = true);

                        try {
                          await updateUser(updatedData: {
                            'symptoms': symptomsText
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList(),
                          });

                          if (!mounted) return;

                          setState(() {
                            _initialSymptoms = symptomsText;
                            _hasChanges = false;
                            _isSaving = false;
                          });
                          if (!mounted) return;

                          setState(() => _isSaving = false);
                        } catch (e) {
                          if (!context.mounted) return;

                          setState(() => _isSaving = false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Failed to save symptoms, please try again!')),
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
