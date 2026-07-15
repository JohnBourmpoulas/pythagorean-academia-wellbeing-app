import 'dart:io';

import '../services/api_service.dart';

class ProfileRepository {
  Future<Map<String, dynamic>?> getProfile() async {
    final response = await ApiService.get(
      '/profile/get.php',
      auth: true,
    );

    if (response['success'] != true) return null;

    return Map<String, dynamic>.from(
      response['profile'] ?? response['data'] ?? {},
    );
  }

  Future<bool> hasCompletedOnboarding() async {
    final profile = await getProfile();

    if (profile == null || profile.isEmpty) return false;

    final completed =
        profile['onboarding_completed'] ??
            profile['completed'] ??
            profile['profile_completed'];

    return completed.toString() == '1' || completed == true;
  }

  Future<bool> saveProfile({
    required int age,
    required String profession,
    required double heightCm,
    required double weightKg,
    required double bmi,
    required String nutritionHabits,
    required String smokingHabits,
    required String physicalActivity,
    required String sleepQuality,
    required String goals,
  }) async {
    final response = await ApiService.post(
      '/profile/save_onboarding.php',
      {
        'age': age,
        'profession': profession,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'bmi': bmi,
        'nutrition_habits': nutritionHabits,
        'smoking_habits': smokingHabits,
        'physical_activity': physicalActivity,
        'sleep_quality': sleepQuality,
        'goals': goals,
        'onboarding_completed': 1,
      },
      auth: true,
    );

    return response['success'] == true;
  }

  Future<String?> uploadProfilePhoto(File imageFile) async {
    final response = await ApiService.uploadProfilePhoto(imageFile);

    if (response['success'] != true) return null;

    return response['profile_photo']?.toString();
  }
}