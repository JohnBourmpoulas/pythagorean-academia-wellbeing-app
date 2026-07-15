import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';
import '../../services/api_service.dart';
import '../../widgets/app_widgets.dart';
import 'interested_home_screen.dart';

class OnboardingGoalsScreen extends StatefulWidget {
  final int age;
  final String profession;
  final String nutritionHabits;
  final String smokingHabits;
  final String physicalActivity;
  final String sleepQuality;
  final double heightCm;
  final double weightKg;

  const OnboardingGoalsScreen({
    super.key,
    required this.age,
    required this.profession,
    required this.nutritionHabits,
    required this.smokingHabits,
    required this.physicalActivity,
    required this.sleepQuality,
    required this.heightCm,
    required this.weightKg,
  });

  @override
  State<OnboardingGoalsScreen> createState() => _OnboardingGoalsScreenState();
}

class _OnboardingGoalsScreenState extends State<OnboardingGoalsScreen> {
  final goalsController = TextEditingController();
  final AuthRepository authRepository = AuthRepository();

  bool isLoading = false;

  double calculateBmi() {
    final heightMeters = widget.heightCm / 100;
    return widget.weightKg / (heightMeters * heightMeters);
  }

  Future<void> submitOnboarding() async {
    if (goalsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your goals')),
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.post(
      '/profile/save_onboarding.php',
      {
        'age': widget.age,
        'profession': widget.profession,
        'height_cm': widget.heightCm,
        'weight_kg': widget.weightKg,
        'bmi': calculateBmi(),
        'nutrition_habits': widget.nutritionHabits,
        'smoking_habits': widget.smokingHabits,
        'physical_activity': widget.physicalActivity,
        'sleep_quality': widget.sleepQuality,
        'goals': goalsController.text.trim(),
        'onboarding_completed': 1,
      },
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not save onboarding',
          ),
        ),
      );
      return;
    }

    final AppUser? currentUser = await authRepository.me();

    if (!mounted) return;

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onboarding completed successfully')),
    );

    if (currentUser == null) {
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => InterestedHomeScreen(user: currentUser),
      ),
          (_) => false,
    );
  }

  @override
  void dispose() {
    goalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calculateBmi();

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'Personal\nGoals'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Final step',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Estimated BMI: ${bmi.toStringAsFixed(1)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 22),
                      AppTextField(
                        label: 'Goals',
                        hint: 'Stress management, better sleep, wellbeing...',
                        controller: goalsController,
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: isLoading ? 'Please wait...' : 'Complete',
                        onPressed:
                        isLoading ? () {} : () => submitOnboarding(),
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