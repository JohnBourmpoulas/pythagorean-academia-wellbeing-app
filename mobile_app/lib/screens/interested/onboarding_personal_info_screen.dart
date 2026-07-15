import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'onboarding_lifestyle_screen.dart';

class OnboardingPersonalInfoScreen extends StatefulWidget {
  const OnboardingPersonalInfoScreen({super.key});

  @override
  State<OnboardingPersonalInfoScreen> createState() =>
      _OnboardingPersonalInfoScreenState();
}

class _OnboardingPersonalInfoScreenState
    extends State<OnboardingPersonalInfoScreen> {
  final ageController = TextEditingController();
  final professionController = TextEditingController();

  void goNext() {
    final age = int.tryParse(ageController.text.trim());

    if (ageController.text.trim().isEmpty ||
        professionController.text.trim().isEmpty ||
        age == null ||
        age <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill valid personal information')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingLifestyleScreen(
          age: age,
          profession: professionController.text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ageController.dispose();
    professionController.dispose();
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
                _topBar(context, 'Personal\nInformation'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tell us about you',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 22),
                      AppTextField(
                        label: 'Age',
                        hint: '30',
                        controller: ageController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Profession',
                        hint: 'Software Engineer',
                        controller: professionController,
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