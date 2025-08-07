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
            ElevatedButton(
                onPressed: () async {
                  await deleteUser();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: const Text("Delete Data"))
          ],
        ),
      ),
    );
  }
}
