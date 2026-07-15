import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/application_repository.dart';
import '../../widgets/app_widgets.dart';
import 'my_applications_screen.dart';
import 'program_activities_screen.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final Program program;

  const ProgramDetailsScreen({
    super.key,
    required this.program,
  });

  @override
  State<ProgramDetailsScreen> createState() => _ProgramDetailsScreenState();
}

class _ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  final ApplicationRepository applicationRepository = ApplicationRepository();

  bool isLoading = false;

  Future<void> applyToProgram() async {
    setState(() => isLoading = true);

    final success = await applicationRepository.applyToProgram(
      programId: widget.program.id,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not submit application'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application submitted successfully'),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MyApplicationsScreen(),
      ),
    );
  }

  void openActivities() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramActivitiesScreen(program: widget.program),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, program.shortTitle),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        program.description,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 19,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Duration',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${program.durationWeeks} weeks',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Status',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        program.status,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'View Activities',
                  onPressed: openActivities,
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  text: isLoading ? 'Please wait...' : 'Apply Now',
                  onPressed: isLoading ? () {} : () => applyToProgram(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, String title) {
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
        Expanded(
          child: Text(
            title.isEmpty ? 'Program Details' : title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}