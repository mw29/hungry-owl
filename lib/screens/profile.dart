import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/screens/terms_of_service.dart';
import 'package:hungryowl/screens/privacy_policy.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Data?'),
                        content: const Text(
                            'This action is irreversible and will permanently delete all your data.'),
                        actionsAlignment: MainAxisAlignment.center,
                        actions: <Widget>[
                          ElevatedButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                            onPressed: () async {
                              await deleteUser();
                              if (context.mounted) {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text("Delete Data")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen()));
                  },
                  child: const Text("Privacy Policy"),
                ),
                Text(
                  " • ",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const TermsOfServiceScreen()));
                  },
                  child: const Text("Terms of Service"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
