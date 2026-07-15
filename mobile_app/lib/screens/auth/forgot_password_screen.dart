import 'package:flutter/material.dart';
import '../../widgets/app_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: WhiteCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline_rounded,
                      size: 54,
                      color: Color(0xFF6A5CFF),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Reset\nPassword',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF0F3D84),
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Enter your email to receive reset instructions',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      label: 'Email',
                      hint: 'your.email@example.com',
                      controller: emailController,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Send Reset Link',
                      onPressed: () {},
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}