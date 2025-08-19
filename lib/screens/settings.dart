import 'package:flutter/material.dart';
import 'package:hungryowl/screens/profile.dart';
import 'package:hungryowl/screens/symptom_settings.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
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
          // ListTile(
          //   title: const Text('Rate HungryOwl'),
          //   leading: const Icon(Icons.star),
          //   onTap: () async {
          //     final Uri url = Uri.parse('https://www.apple.com/app-store/');
          //     if (!await launchUrl(url)) {
          //       throw Exception('Could not launch $url');
          //     }
          //   },
          // ),
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
