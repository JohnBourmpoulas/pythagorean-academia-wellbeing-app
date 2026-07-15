import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../interested/change_password_screen.dart';
import '../interested/contact_screen.dart';
import '../interested/delete_account_screen.dart';
import '../interested/privacy_policy_screen.dart';
import '../interested/terms_screen.dart';

class ParticipantSettingsScreen extends StatelessWidget {
  const ParticipantSettingsScreen({super.key});

  Future<void> logout(BuildContext context) async {
    await ApiService.clearToken();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> leaveProgram(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Program'),
        content: const Text(
          'Are you sure you want to leave your current program?\n\n'
              'Your account will return to Interested User status. '
              'You will be able to apply for another program later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave Program'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await ApiService.post(
      '/participant/leave_program.php',
      {},
      auth: true,
    );

    if (!context.mounted) return;

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not leave program',
          ),
        ),
      );
      return;
    }

    await ApiService.clearToken();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  void open(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context),
                const SizedBox(height: 28),
                _WhiteCard(
                  child: Column(
                    children: [
                      _row(
                        icon: Icons.lock_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () => open(context, const ChangePasswordScreen()),
                      ),
                      _row(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'Read how your data is handled',
                        onTap: () => open(context, const PrivacyPolicyScreen()),
                      ),
                      _row(
                        icon: Icons.article_rounded,
                        title: 'Terms & Conditions',
                        subtitle: 'Read app usage terms',
                        onTap: () => open(context, const TermsScreen()),
                      ),
                      _row(
                        icon: Icons.contact_support_rounded,
                        title: 'Contact Us',
                        subtitle: 'Get help from the program team',
                        onTap: () => open(context, const ContactScreen()),
                      ),
                      _row(
                        icon: Icons.exit_to_app_rounded,
                        title: 'Leave Program',
                        subtitle:
                        'Leave current program and return as Interested User',
                        onTap: () => leaveProgram(context),
                      ),
                      _row(
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        subtitle: 'Sign out from this device',
                        onTap: () => logout(context),
                      ),
                      const SizedBox(height: 12),
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
                              open(context, const DeleteAccountScreen()),
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
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

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFE8F1FF),
        child: Icon(icon, color: const Color(0xFF2F61D2)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Gradient extends StatelessWidget {
  final Widget child;

  const _Gradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3D84),
            Color(0xFF2F61D2),
            Color(0xFF5A5CF6),
          ],
        ),
      ),
      child: child,
    );
  }
}