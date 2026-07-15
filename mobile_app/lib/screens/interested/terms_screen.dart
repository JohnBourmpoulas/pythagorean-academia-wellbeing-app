import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                _topBar(context, 'Terms &\nConditions'),
                const SizedBox(height: 28),
                const WhiteCard(
                  child: Text(
                    'By using Pythagorean Academia, users agree to provide accurate information and use the platform responsibly.\n\n'
                        'Program information, educational material and wellness content are provided for guidance and participation purposes. They do not replace professional medical advice.\n\n'
                        'Users are responsible for keeping their login credentials secure.\n\n'
                        'The platform may update its features, policies or available programs when required.',
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