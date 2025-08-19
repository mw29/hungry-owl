import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/screens/profile.dart';
import 'package:hungryowl/screens/symptom_settings.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(usersProvider);

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: const Text('Symptom Settings'),
            leading: const Icon(Icons.thermostat),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SymptomSettings(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          userAsyncValue.when(
            data: (user) {
              if (user != null && !user.leftReview) {
                return ListTile(
                  title: const Text('Rate HungryOwl'),
                  leading: const Icon(Icons.star),
                  onTap: () async {
                    final InAppReview inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                      await updateUser(updatedData: {'leftReview': true});
                    }
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
          ListTile(
            title: const Text('View Source Code'),
            leading: const Icon(Icons.code),
            onTap: () async {
              final Uri url = Uri.parse('https://github.com/mw29/hungry-owl');
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
            },
          ),
        ],
      ),
    );
  }
}
