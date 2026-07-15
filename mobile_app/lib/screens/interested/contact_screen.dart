import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
                _topBar(context, 'Contact\nUs'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Support',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'For questions about your account, applications or program participation, please contact the Pythagorean Academia team.',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Email',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'support@pythagorean.gr',
                        style: TextStyle(
                          color: Color(0xFF17213A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Phone',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '+30 210 0000000',
                        style: TextStyle(
                          color: Color(0xFF17213A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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