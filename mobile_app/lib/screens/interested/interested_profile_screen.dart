import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/app_widgets.dart';
import 'change_password_screen.dart';
import 'contact_screen.dart';
import 'delete_account_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class InterestedProfileScreen extends StatefulWidget {
  const InterestedProfileScreen({super.key});

  @override
  State<InterestedProfileScreen> createState() =>
      _InterestedProfileScreenState();
}

class _InterestedProfileScreenState extends State<InterestedProfileScreen> {
  final ProfileRepository profileRepository = ProfileRepository();

  Map<String, dynamic>? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final data = await profileRepository.getProfile();

    if (!mounted) return;

    setState(() {
      profile = data;
      isLoading = false;
    });
  }

  Future<void> openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditInterestedProfileScreen(profile: profile ?? {}),
      ),
    );

    await loadProfile();
  }

  void openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  String value(String key) {
    final v = profile?[key];
    if (v == null || v.toString().trim().isEmpty) return 'Not provided';
    return v.toString();
  }

  String _photoUrl(String path) {
    return '${ApiConfig.serverUrl}/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'My\nProfile'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    children: [
                      _profilePhoto(),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Edit Profile',
                        onPressed: openEditProfile,
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'Change Password',
                        onPressed: () =>
                            openScreen(const ChangePasswordScreen()),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'Privacy Policy',
                        onPressed: () =>
                            openScreen(const PrivacyPolicyScreen()),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'Terms & Conditions',
                        onPressed: () => openScreen(const TermsScreen()),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: 'Contact Us',
                        onPressed: () => openScreen(const ContactScreen()),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () =>
                              openScreen(const DeleteAccountScreen()),
                          child: const Text('Delete Account'),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _sectionTitle('Basic Information'),
                      _info('Age', value('age')),
                      _info('Profession', value('profession')),
                      _sectionTitle('Health Data'),
                      _info('Height', '${value('height_cm')} cm'),
                      _info('Weight', '${value('weight_kg')} kg'),
                      _info('BMI', value('bmi')),
                      _sectionTitle('Lifestyle'),
                      _info('Nutrition Habits', value('nutrition_habits')),
                      _info('Smoking Habits', value('smoking_habits')),
                      _info(
                        'Physical Activity',
                        value('physical_activity'),
                      ),
                      _info('Sleep Quality', value('sleep_quality')),
                      _sectionTitle('Personal Goals'),
                      _info('Goals', value('goals')),
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

  Widget _profilePhoto() {
    ImageProvider? imageProvider;

    final photo = profile?['profile_photo']?.toString();

    if (photo != null && photo.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl(photo));
    }

    return CircleAvatar(
      radius: 58,
      backgroundColor: const Color(0xFFE8F1FF),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(
        Icons.person,
        size: 62,
        color: Color(0xFF2F61D2),
      )
          : null,
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF17213A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

class EditInterestedProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditInterestedProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditInterestedProfileScreen> createState() =>
      _EditInterestedProfileScreenState();
}

class _EditInterestedProfileScreenState
    extends State<EditInterestedProfileScreen> {
  final ProfileRepository profileRepository = ProfileRepository();

  final ageController = TextEditingController();
  final professionController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final nutritionController = TextEditingController();
  final smokingController = TextEditingController();
  final activityController = TextEditingController();
  final sleepController = TextEditingController();
  final goalsController = TextEditingController();

  File? selectedImage;
  String? profilePhoto;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    ageController.text = widget.profile['age']?.toString() ?? '';
    professionController.text = widget.profile['profession']?.toString() ?? '';
    heightController.text = widget.profile['height_cm']?.toString() ?? '';
    weightController.text = widget.profile['weight_kg']?.toString() ?? '';
    nutritionController.text =
        widget.profile['nutrition_habits']?.toString() ?? '';
    smokingController.text =
        widget.profile['smoking_habits']?.toString() ?? '';
    activityController.text =
        widget.profile['physical_activity']?.toString() ?? '';
    sleepController.text = widget.profile['sleep_quality']?.toString() ?? '';
    goalsController.text = widget.profile['goals']?.toString() ?? '';
    profilePhoto = widget.profile['profile_photo']?.toString();
  }

  Future<void> pickProfilePhoto() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  double calculateBmi(double heightCm, double weightKg) {
    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  Future<void> saveProfile() async {
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(heightController.text.trim());
    final weight = double.tryParse(weightController.text.trim());

    if (age == null ||
        height == null ||
        weight == null ||
        age <= 0 ||
        height <= 0 ||
        weight <= 0 ||
        professionController.text.trim().isEmpty ||
        nutritionController.text.trim().isEmpty ||
        smokingController.text.trim().isEmpty ||
        activityController.text.trim().isEmpty ||
        sleepController.text.trim().isEmpty ||
        goalsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isSaving = true);

    if (selectedImage != null) {
      final uploadedPath =
      await profileRepository.uploadProfilePhoto(selectedImage!);

      if (uploadedPath != null) {
        profilePhoto = uploadedPath;
      } else {
        if (!mounted) return;

        setState(() => isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload profile photo')),
        );
        return;
      }
    }

    final success = await profileRepository.saveProfile(
      age: age,
      profession: professionController.text.trim(),
      heightCm: height,
      weightKg: weight,
      bmi: calculateBmi(height, weight),
      nutritionHabits: nutritionController.text.trim(),
      smokingHabits: smokingController.text.trim(),
      physicalActivity: activityController.text.trim(),
      sleepQuality: sleepController.text.trim(),
      goals: goalsController.text.trim(),
    );

    if (!mounted) return;

    setState(() => isSaving = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save profile')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    ageController.dispose();
    professionController.dispose();
    heightController.dispose();
    weightController.dispose();
    nutritionController.dispose();
    smokingController.dispose();
    activityController.dispose();
    sleepController.dispose();
    goalsController.dispose();
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
                _topBar(context, 'Edit\nProfile'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _profilePhoto()),
                      const SizedBox(height: 26),
                      _sectionTitle('Basic Information'),
                      AppTextField(
                        label: 'Age',
                        hint: '30',
                        controller: ageController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Profession',
                        hint: 'Student, Engineer, Doctor...',
                        controller: professionController,
                      ),
                      _sectionTitle('Health Data'),
                      const Text(
                        'Only necessary wellbeing data is stored for program personalization.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Height (cm)',
                        hint: '178',
                        controller: heightController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Weight (kg)',
                        hint: '75',
                        controller: weightController,
                      ),
                      _sectionTitle('Lifestyle'),
                      AppTextField(
                        label: 'Nutrition Habits',
                        hint: 'Balanced diet',
                        controller: nutritionController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Smoking Habits',
                        hint: 'Non-smoker',
                        controller: smokingController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Physical Activity',
                        hint: 'Low / Moderate / High',
                        controller: activityController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Sleep Quality',
                        hint: 'Poor / Average / Good',
                        controller: sleepController,
                      ),
                      _sectionTitle('Personal Goals'),
                      AppTextField(
                        label: 'Goals',
                        hint: 'Stress management, wellbeing...',
                        controller: goalsController,
                      ),
                      const SizedBox(height: 30),
                      PrimaryButton(
                        text: isSaving ? 'Please wait...' : 'Save Changes',
                        onPressed: isSaving ? () {} : saveProfile,
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

  Widget _profilePhoto() {
    ImageProvider? imageProvider;

    if (selectedImage != null) {
      imageProvider = FileImage(selectedImage!);
    } else if (profilePhoto != null && profilePhoto!.isNotEmpty) {
      imageProvider = NetworkImage('${ApiConfig.serverUrl}/$profilePhoto');
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 54,
          backgroundColor: const Color(0xFFE8F1FF),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(
            Icons.person,
            size: 58,
            color: Color(0xFF2F61D2),
          )
              : null,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: pickProfilePhoto,
          icon: const Icon(Icons.photo_camera),
          label: const Text('Change Profile Photo'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 14),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontSize: 24,
          fontWeight: FontWeight.bold,
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