import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_widgets.dart';
import '../admin/admin_home_screen.dart';
import '../interested/interested_home_screen.dart';
import '../participant/participant_home_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill email and password')),
      );
      return;
    }

    setState(() => isLoading = true);

    final user = await authRepository.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authRepository.lastError ?? 'Invalid email or password'),
        ),
      );
      return;
    }

    _openRoleScreen(user);
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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.14),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 22),
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
                  const SizedBox(height: 10),
                  const Text(
                    'Track your wellness and daily progress',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 34),
                  WhiteCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Email',
                          hint: 'your.email@example.com',
                          controller: emailController,
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Password',
                          hint: '••••••••',
                          obscureText: true,
                          controller: passwordController,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                        PrimaryButton(
                          text: isLoading ? 'Please wait...' : 'Login',
                          onPressed: isLoading ? () {} : login,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _socialButton('Continue with Apple', Icons.apple),
                  const SizedBox(height: 12),
                  _socialButton('Continue with Google', Icons.g_mobiledata),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(color: Colors.white),
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

  Widget _socialButton(String text, IconData icon) {
    return SizedBox(
      height: 58,
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF17213A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {},
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
