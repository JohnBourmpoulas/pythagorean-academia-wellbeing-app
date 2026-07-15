import 'package:flutter/material.dart';

import '../../models/program_application.dart';
import '../../repositories/application_repository.dart';
import '../../widgets/app_widgets.dart';
import 'admin_review_application_screen.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  final ApplicationRepository applicationRepository = ApplicationRepository();

  late Future<List<ProgramApplication>> applicationsFuture;

  @override
  void initState() {
    super.initState();
    applicationsFuture = applicationRepository.getAdminApplications();
  }

  Future<void> refreshApplications() async {
    setState(() {
      applicationsFuture = applicationRepository.getAdminApplications();
    });
  }

  Future<void> openReview(ProgramApplication application) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminReviewApplicationScreen(application: application),
      ),
    );

    refreshApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshApplications,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context, 'Applications\nQueue'),
                  const SizedBox(height: 30),
                  FutureBuilder<List<ProgramApplication>>(
                    future: applicationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
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
                          'Could not load applications',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        );
                      }

                      final applications = snapshot.data ?? [];

                      if (applications.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'No pending applications',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        );
                      }

                      return Column(
                        children: applications
                            .map(
                              (application) => GestureDetector(
                            onTap: () => openReview(application),
                            child: _applicationCard(application),
                          ),
                        )
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

  Widget _applicationCard(ProgramApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  application.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF0F3D84),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  application.shortTitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3BE),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              application.status,
              style: const TextStyle(color: Color(0xFFB36B00)),
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