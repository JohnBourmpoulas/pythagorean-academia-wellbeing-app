import 'package:flutter/material.dart';

import '../../repositories/account_repository.dart';
import '../../widgets/app_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AccountRepository accountRepository = AccountRepository();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> changePassword() async {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await accountRepository.changePassword(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not change password')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
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
                _topBar(context, 'Change\nPassword'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Current Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: currentPasswordController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'New Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: newPasswordController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Confirm New Password',
                        hint: '••••••••',
                        obscureText: true,
                        controller: confirmPasswordController,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: isLoading ? 'Please wait...' : 'Save Password',
                        onPressed: isLoading ? () {} : changePassword,
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