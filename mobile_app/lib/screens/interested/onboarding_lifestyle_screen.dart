import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'onboarding_body_measurements_screen.dart';

class OnboardingLifestyleScreen extends StatefulWidget {
  final int age;
  final String profession;

  const OnboardingLifestyleScreen({
    super.key,
    required this.age,
    required this.profession,
  });

  @override
  State<OnboardingLifestyleScreen> createState() =>
      _OnboardingLifestyleScreenState();
}

class _OnboardingLifestyleScreenState extends State<OnboardingLifestyleScreen> {
  final nutritionController = TextEditingController();
  final smokingController = TextEditingController();
  final activityController = TextEditingController();
  final sleepController = TextEditingController();

  void goNext() {
    if (nutritionController.text.trim().isEmpty ||
        smokingController.text.trim().isEmpty ||
        activityController.text.trim().isEmpty ||
        sleepController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all lifestyle fields')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingBodyMeasurementsScreen(
          age: widget.age,
          profession: widget.profession,
          nutritionHabits: nutritionController.text.trim(),
          smokingHabits: smokingController.text.trim(),
          physicalActivity: activityController.text.trim(),
          sleepQuality: sleepController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nutritionController.dispose();
    smokingController.dispose();
    activityController.dispose();
    sleepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'Lifestyle\nInformation'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily habits',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      AppTextField(
                        label: 'Nutrition Habits',
                        hint: 'Balanced diet, vegetarian, etc.',
                        controller: nutritionController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Smoking Habits',
                        hint: 'Non-smoker / occasional / daily',
                        controller: smokingController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Physical Activity',
                        hint: 'Low / moderate / high',
                        controller: activityController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Sleep Quality',
                        hint: 'Poor / average / good',
                        controller: sleepController,
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: 'Continue',
                        onPressed: goNext,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context, String title) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}