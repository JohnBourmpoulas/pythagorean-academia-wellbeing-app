import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/admin_repository.dart';
import '../../widgets/app_widgets.dart';

class AdminStatisticsScreen extends StatelessWidget {
  final Program program;

  const AdminStatisticsScreen({
    super.key,
    required this.program,
  });

  Future<Map<String, dynamic>> loadStatistics() {
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
                _topBar(context, 'Statistics'),
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
                  future: loadStatistics(),
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
                          'total_enrolled': 0,
                          'active_participants': 0,
                          'completed': 0,
                          'avg_satisfaction': '0.0/5.0',
                        };

                    return WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _statItem(
                            'Total Enrolled',
                            data['total_enrolled'].toString(),
                          ),
                          _statItem(
                            'Active Participants',
                            data['active_participants'].toString(),
                          ),
                          _statItem(
                            'Completed',
                            data['completed'].toString(),
                          ),
                          _statItem(
                            'Avg Satisfaction',
                            data['avg_satisfaction'].toString(),
                          ),
                        ],
                      ),
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

  Widget _statItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              color: Color(0xFF0F3D84),
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
