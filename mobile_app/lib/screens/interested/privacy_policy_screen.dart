import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                _topBar(context, 'Privacy\nPolicy'),
                const SizedBox(height: 28),
                const WhiteCard(
                  child: Text(
                    'Pythagorean Academia collects only the data required for account access, program participation, profile personalization and application management.\n\n'
                        'The data may include name, email, optional phone number, basic profile information, selected wellbeing data and application history.\n\n'
                        'The application does not collect unnecessary personal data. Users may request account deletion or data correction through their profile.\n\n'
                        'Data is stored securely on the server and is used only for the purposes of the platform.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 17,
                      height: 1.45,
                    ),
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