import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/program_repository.dart';
import '../../widgets/app_widgets.dart';
import 'program_details_screen.dart';

class ProgramsCatalogScreen extends StatefulWidget {
  const ProgramsCatalogScreen({super.key});

  @override
  State<ProgramsCatalogScreen> createState() => _ProgramsCatalogScreenState();
}

class _ProgramsCatalogScreenState extends State<ProgramsCatalogScreen> {
  final ProgramRepository programRepository = ProgramRepository();
  final searchController = TextEditingController();

  late Future<List<Program>> programsFuture;

  List<Program> allPrograms = [];
  List<Program> filteredPrograms = [];

  @override
  void initState() {
    super.initState();
    programsFuture = loadPrograms();
  }

  Future<List<Program>> loadPrograms() async {
    final programs = await programRepository.getAllPrograms();

    allPrograms = programs;
    filteredPrograms = programs;

    return programs;
  }

  Future<void> refreshPrograms() async {
    setState(() {
      programsFuture = loadPrograms();
    });
  }

  void filterPrograms(String query) {
    final cleanQuery = query.trim().toLowerCase();

    setState(() {
      if (cleanQuery.isEmpty) {
        filteredPrograms = allPrograms;
      } else {
        filteredPrograms = allPrograms.where((program) {
          final title = program.title.toLowerCase();
          final shortTitle = program.shortTitle.toLowerCase();
          final description = program.description.toLowerCase();

          return title.contains(cleanQuery) ||
              shortTitle.contains(cleanQuery) ||
              description.contains(cleanQuery);
        }).toList();
      }
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
  void dispose() {
    searchController.dispose();
    super.dispose();
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
                  _topBar(context, 'Programs\nCatalog'),
                  const SizedBox(height: 28),
                  _searchBox(),
                  const SizedBox(height: 28),
                  FutureBuilder<List<Program>>(
                    future: programsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          allPrograms.isEmpty) {
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
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      }

                      if (filteredPrograms.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'No programs found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: filteredPrograms.map(_programCard).toList(),
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

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: searchController,
        onChanged: filterPrograms,
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: Color(0xFF2F61D2),
          ),
          hintText: 'Search programs',
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
                Icons.school_rounded,
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