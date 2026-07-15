import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/admin_repository.dart';
import '../../widgets/app_widgets.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  final Program program;

  const AdminAnalyticsScreen({
    super.key,
    required this.program,
  });

  Future<Map<String, dynamic>> loadAnalytics() {
    return AdminRepository().getProgramStatistics(program.id);
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
                _topBar(context, 'Analytics'),
                const SizedBox(height: 14),
                Text(
                  program.shortTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 34),
                FutureBuilder<Map<String, dynamic>>(
                  future: loadAnalytics(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }

                    final data = snapshot.data ??
                        {
                          'completion_rate': 0,
                          'avg_progress': 0,
                        };

                    return Column(
                      children: [
                        _metricCard(
                          Icons.bar_chart,
                          'Completion Rate',
                          '${data['completion_rate']}%',
                        ),
                        _metricCard(
                          Icons.trending_up,
                          'Avg Progress',
                          '${data['avg_progress']}%',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F61D2)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF0F3D84),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 42,
              color: Color(0xFF0F3D84),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
