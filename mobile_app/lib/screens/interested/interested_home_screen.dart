import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../../widgets/app_widgets.dart';
import '../auth/login_screen.dart';
import 'interested_profile_screen.dart';
import 'my_applications_screen.dart';
import 'onboarding_personal_info_screen.dart';
import 'programs_catalog_screen.dart';

class InterestedHomeScreen extends StatefulWidget {
  final AppUser user;

  const InterestedHomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<InterestedHomeScreen> createState() => _InterestedHomeScreenState();
}

class _InterestedHomeScreenState extends State<InterestedHomeScreen> {
  final AuthRepository authRepository = AuthRepository();
  final ProfileRepository profileRepository = ProfileRepository();

  bool checkingProfile = true;
  bool onboardingCompleted = false;
  bool onboardingOpenedAutomatically = false;

  @override
  void initState() {
    super.initState();
    checkOnboardingState();
  }

  Future<void> checkOnboardingState() async {
    final completed = await profileRepository.hasCompletedOnboarding();

    if (!mounted) return;

    setState(() {
      onboardingCompleted = completed;
      checkingProfile = false;
    });

    if (!completed && !onboardingOpenedAutomatically) {
      onboardingOpenedAutomatically = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingPersonalInfoScreen(),
        ),
      );

      await refreshOnboardingState();
    }
  }

  Future<void> refreshOnboardingState() async {
    setState(() {
      checkingProfile = true;
    });

    final completed = await profileRepository.hasCompletedOnboarding();

    if (!mounted) return;

    setState(() {
      onboardingCompleted = completed;
      checkingProfile = false;
    });

    if (!completed && !onboardingOpenedAutomatically) {
      onboardingOpenedAutomatically = true;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingPersonalInfoScreen(),
        ),
      );

      await refreshOnboardingState();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const InterestedProfileScreen(),
      ),
    );

    await refreshOnboardingState();
  }

  void openMyApplications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyApplicationsScreen(),
      ),
    );
  }

  void openProgramsCatalog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProgramsCatalogScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkingProfile) {
      return const Scaffold(
        body: AppGradientBackground(
          child: SafeArea(
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshOnboardingState,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 34),
                  WhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: Color(0xFF0F3D84),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 22),
                        PrimaryButton(
                          text: 'My Profile',
                          onPressed: openProfile,
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          text: 'My Applications',
                          onPressed: openMyApplications,
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          text: 'Programs Catalog',
                          onPressed: openProgramsCatalog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Welcome,\n${widget.user.fullName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
          ),
          onPressed: logout,
          child: const Text('Logout'),
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(
            Icons.person_outline,
            color: Color(0xFF2F61D2),
          ),
        ),
      ],
    );
  }
}