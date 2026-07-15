import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../widgets/app_widgets.dart';

class ProgramActivitiesScreen extends StatelessWidget {
  final Program program;

  const ProgramActivitiesScreen({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': 'Initial Assessment',
        'description': 'Complete the first program assessment.',
        'icon': Icons.assignment_rounded,
      },
      {
        'title': 'Daily Reflection',
        'description': 'Record your daily wellness reflection.',
        'icon': Icons.edit_note_rounded,
      },
      {
        'title': 'Guided Practice',
        'description': 'Follow the recommended wellbeing activity.',
        'icon': Icons.self_improvement_rounded,
      },
      {
        'title': 'Progress Review',
        'description': 'Track your progress during the program.',
        'icon': Icons.trending_up_rounded,
      },
    ];

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'Program\nActivities'),
                const SizedBox(height: 18),
                Text(
                  program.shortTitle.isEmpty ? program.title : program.shortTitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                ...activities.map(
                      (activity) => _activityCard(
                    icon: activity['icon'] as IconData,
                    title: activity['title'] as String,
                    description: activity['description'] as String,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _activityCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(
              icon,
              color: const Color(0xFF2F61D2),
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
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
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}