import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/screens/home.dart';
import 'package:hungryowl/widgets/symptom_editor.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  List<String> _symptoms = [];

  @override
  void initState() {
    super.initState();
    final user = ref.read(usersProvider).value;
    if (user != null) {
      setState(() {
        _symptoms = user.symptoms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildWelcomePage(),
          _buildSymptomPage(),
          _buildCompletionPage(),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "🦉",
              style: TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
            Text(
              'Welcome to\nHungryOwl',
              style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                  fontSize: 40),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Your symptom-free eating companion",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                // Text(
                //   '🌡️ Define your symptoms',
                //   textAlign: TextAlign.center,
                // ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '📸 Take a photo of any food or ingredient list',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '📊 Get personalized risk scores for your symptoms',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '📝 See which ingredients might affect you most',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  '💡 Make informed choices before you eat',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomPage() {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'What symptoms do you experience?',
              style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'These symptoms will be used to calculate risk scores and identify risky ingredients specific to you. You can edit this list any time.',
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: SymptomEditor(
                initialSymptoms: _symptoms,
                onSymptomsChanged: (newSymptoms) {
                  setState(() {
                    _symptoms = newSymptoms;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_symptoms.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Text('Next'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPage() {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '🎉 You’re All Set!',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'You can now start scanning your food and preventing your symptoms.',
              style: textTheme.titleMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final user = ref.read(usersProvider).value;
                if (user != null) {
                  await updateUser(
                    updatedData: {
                      'onboarded': true,
                      'symptoms': _symptoms,
                    },
                  );
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: const Text(
                'Start Scanning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
