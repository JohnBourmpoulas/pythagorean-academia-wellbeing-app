import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'onboarding_goals_screen.dart';

class OnboardingBodyMeasurementsScreen extends StatefulWidget {
  final int age;
  final String profession;
  final String nutritionHabits;
  final String smokingHabits;
  final String physicalActivity;
  final String sleepQuality;

  const OnboardingBodyMeasurementsScreen({
    super.key,
    required this.age,
    required this.profession,
    required this.nutritionHabits,
    required this.smokingHabits,
    required this.physicalActivity,
    required this.sleepQuality,
  });

  @override
  State<OnboardingBodyMeasurementsScreen> createState() =>
      _OnboardingBodyMeasurementsScreenState();
}

class _OnboardingBodyMeasurementsScreenState
    extends State<OnboardingBodyMeasurementsScreen> {
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  double get bmi {
    final height = double.tryParse(heightController.text.trim()) ?? 0;
    final weight = double.tryParse(weightController.text.trim()) ?? 0;

    if (height <= 0 || weight <= 0) return 0;

    final meters = height / 100;
    return weight / (meters * meters);
  }

  void goNext() {
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill valid body measurements')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingGoalsScreen(
          age: widget.age,
          profession: widget.profession,
          nutritionHabits: widget.nutritionHabits,
          smokingHabits: widget.smokingHabits,
          physicalActivity: widget.physicalActivity,
          sleepQuality: widget.sleepQuality,
          heightCm: height,
          weightKg: weight,
        ),
      ),
    );
  }

  @override
  void dispose() {
    heightController.dispose();
    weightController.dispose();
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
                _header(context, 'Body\nMeasurements', 'Step 3 of 4'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Height (cm)',
                        hint: '178',
                        controller: heightController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Weight (kg)',
                        hint: '75',
                        controller: weightController,
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'BMI: ${bmi.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
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

  Widget _header(BuildContext context, String title, String step) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1.15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}