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
  Widget build(BuildContext context) {
    final currUser = ref.watch(usersProvider).value;
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
              decoration: const InputDecoration(labelText: 'Symptoms'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {print('lol')},
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
