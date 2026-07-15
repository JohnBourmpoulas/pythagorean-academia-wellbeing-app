import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/program_repository.dart';
import '../../widgets/app_widgets.dart';
import 'admin_create_program_screen.dart';
import 'admin_edit_program_screen.dart';
import 'admin_program_details_screen.dart';

class AdminProgramsScreen extends StatefulWidget {
  const AdminProgramsScreen({super.key});

  @override
  State<AdminProgramsScreen> createState() => _AdminProgramsScreenState();
}

class _AdminProgramsScreenState extends State<AdminProgramsScreen> {
  final ProgramRepository programRepository = ProgramRepository();

  late Future<List<Program>> programsFuture;

  @override
  void initState() {
    super.initState();
    programsFuture = programRepository.getAdminPrograms();
  }

  Future<void> refreshPrograms() async {
    setState(() {
      programsFuture = programRepository.getAdminPrograms();
    });
  }

  Future<void> openCreateProgram() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminCreateProgramScreen()),
    );

    refreshPrograms();
  }

  Future<void> openEditProgram(Program program) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditProgramScreen(program: program),
      ),
    );

    refreshPrograms();
  }

  Future<void> openProgramDetails(Program program) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminProgramDetailsScreen(program: program),
      ),
    );

    refreshPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshPrograms,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context, 'My Programs'),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2F61D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      onPressed: openCreateProgram,
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Create New Program',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<Program>>(
                    future: programsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Could not load programs',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      }

                      final programs = snapshot.data ?? [];

                      if (programs.isEmpty) {
                        return const Text(
                          'No programs found',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        );
                      }

                      return Column(
                        children: programs
                            .map((program) => _programCard(context, program))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _programCard(BuildContext context, Program program) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            program.shortTitle,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF0F3D84),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${program.status}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _smallButton('Edit Program', () => openEditProgram(program)),
              const SizedBox(width: 12),
              _smallButton('View', () => openProgramDetails(program)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE8F1FF),
        foregroundColor: const Color(0xFF2F61D2),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(text),
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
