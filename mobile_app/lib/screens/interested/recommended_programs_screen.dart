import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/program_repository.dart';
import '../../widgets/app_widgets.dart';
import 'program_details_screen.dart';

class RecommendedProgramsScreen extends StatefulWidget {
  const RecommendedProgramsScreen({super.key});

  @override
  State<RecommendedProgramsScreen> createState() =>
      _RecommendedProgramsScreenState();
}

class _RecommendedProgramsScreenState extends State<RecommendedProgramsScreen> {
  final ProgramRepository programRepository = ProgramRepository();

  late Future<List<Program>> recommendedProgramsFuture;

  @override
  void initState() {
    super.initState();
    recommendedProgramsFuture = loadRecommendedPrograms();
  }

  Future<List<Program>> loadRecommendedPrograms() async {
    final programs = await programRepository.getAllPrograms();

    final activePrograms = programs
        .where((program) => program.status.toLowerCase() == 'active')
        .toList();

    if (activePrograms.isEmpty) {
      return programs;
    }

    return activePrograms;
  }

  Future<void> refreshPrograms() async {
    setState(() {
      recommendedProgramsFuture = loadRecommendedPrograms();
    });
  }

  void openProgramDetails(Program program) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProgramDetailsScreen(program: program),
      ),
    );
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
                  _topBar(context, 'Recommended\nPrograms'),
                  const SizedBox(height: 18),
                  const Text(
                    'Based on the available active programs in the platform.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 30),
                  FutureBuilder<List<Program>>(
                    future: recommendedProgramsFuture,
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
                          'Could not load recommended programs',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      }

                      final programs = snapshot.data ?? [];

                      if (programs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'No recommended programs available yet.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: programs.map(_programCard).toList(),
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

  Widget _programCard(Program program) {
    return GestureDetector(
      onTap: () => openProgramDetails(program),
      child: Container(
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
                Icons.recommend_rounded,
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
                    program.shortTitle.isEmpty
                        ? program.title
                        : program.shortTitle,
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${program.durationWeeks} weeks • ${program.status}',
                    style: const TextStyle(
                      color: Color(0xFF2F61D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
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