import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../widgets/app_widgets.dart';
import 'admin_analytics_screen.dart';
import 'admin_statistics_screen.dart';

class AdminProgramDetailsScreen extends StatelessWidget {
  final Program program;

  const AdminProgramDetailsScreen({
    super.key,
    required this.program,
  });

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
                _topBar(context, 'Program\nDetails'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.shortTitle,
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1.25,
                          color: Color(0xFF0F3D84),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        program.description,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Duration\n${program.durationWeeks} weeks',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFF0F3D84),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Status\n${program.status}',
                              style: TextStyle(
                                fontSize: 20,
                                color: program.status == 'active'
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                _menuCard(
                  context,
                  Icons.bar_chart,
                  'Analytics',
                  'View program analytics',
                  AdminAnalyticsScreen(program: program),
                ),
                _menuCard(
                  context,
                  Icons.pie_chart,
                  'Statistics',
                  'View detailed statistics',
                  AdminStatisticsScreen(program: program),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFE8F1FF),
              child: Icon(icon, color: const Color(0xFF2F61D2)),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF0F3D84),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
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
