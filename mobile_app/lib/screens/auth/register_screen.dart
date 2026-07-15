import 'package:flutter/material.dart';

import '../../repositories/auth_repository.dart';
import '../../widgets/app_widgets.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final AuthRepository authRepository = AuthRepository();

  bool isLoading = false;

  Future<void> register() async {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await authRepository.registerInterestedUser(
      fullName: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create account')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created successfully')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const SizedBox(height: 60),
                WhiteCard(
                  child: Column(
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Maria Santos',
                        controller: nameController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Email',
                        hint: 'your.email@example.com',
                        controller: emailController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: passwordController,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirm Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: confirmController,
                      ),
                      const SizedBox(height: 26),
                      PrimaryButton(
                        text: isLoading ? 'Please wait...' : 'Register',
                        onPressed: isLoading ? () {} : () => register(),
                      ),
                      TextButton(
                        onPressed:
                        isLoading ? null : () => Navigator.pop(context),
                        child: const Text('Back to Login'),
                      ),
                      const Text(
                        'All users register here • No admin approval required',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
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
}