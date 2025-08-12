import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Last Updated: August 12, 2025',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'By using the Scan App, you agree to the following terms and conditions. '
                'Please read them carefully.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Use of the Scan App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'The Scan App is provided for personal use only. You agree not to misuse the Scan App '
                'or use it for any unlawful purposes. All features are provided as-is, '
                'without any guarantee of availability or functionality.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'No Data Storage',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'I do not collect, store, or retain any personal information through the Scan App. '
                'Any prompts or queries sent through the Gemini API are subject to Google’s terms '
                'and privacy policy.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Limitation of Liability',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'I am not responsible for any damages, losses, or issues that may occur '
                'from using the Scan App, including but not limited to data loss, device issues, '
                'or third-party service interruptions.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Changes to Terms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'I may update these Terms of Service from time to time. Continued use of the Scan App '
                'after changes have been made will constitute your acceptance of the updated terms.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
