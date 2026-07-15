import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_widgets.dart';
import '../admin/admin_home_screen.dart';
import '../interested/interested_home_screen.dart';
import '../participant/participant_home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    try {
      final user = await authRepository.me().timeout(
        const Duration(seconds: 3),
      );

      if (!mounted) return;

      if (user != null) {
        _openRoleScreen(user);
        return;
      }

      _goToLogin();
    } catch (_) {
      if (!mounted) return;
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _openRoleScreen(AppUser user) {
    Widget screen;

    if (user.role == 'admin') {
      screen = AdminHomeScreen(user: user);
    } else if (user.role == 'participant') {
      screen = const ParticipantHomeScreen();
    } else {
      screen = InterestedHomeScreen(user: user);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 118,
                    height: 118,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pythagorean\nAcademia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
