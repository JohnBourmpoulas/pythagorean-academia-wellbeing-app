import 'package:flutter/material.dart';

import '../../widgets/app_widgets.dart';
import 'my_applications_screen.dart';

class ApplicationPendingScreen extends StatelessWidget {
  const ApplicationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                WhiteCard(
                  child: Column(
                    children: [
                      Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3BE),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Icon(
                          Icons.hourglass_top_rounded,
                          color: Color(0xFFB36B00),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Application Pending',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Your application has been submitted and is waiting for administrator review.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 17,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: 'View My Applications',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MyApplicationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}