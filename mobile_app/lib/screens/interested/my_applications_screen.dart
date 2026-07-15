import 'package:flutter/material.dart';

import '../../models/program_application.dart';
import '../../repositories/application_repository.dart';
import '../../widgets/app_widgets.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  final ApplicationRepository applicationRepository = ApplicationRepository();

  late Future<List<ProgramApplication>> applicationsFuture;

  @override
  void initState() {
    super.initState();
    applicationsFuture = applicationRepository.getUserApplications();
  }

  Future<void> refreshApplications() async {
    setState(() {
      applicationsFuture = applicationRepository.getUserApplications();
    });
  }

  Color _statusColor(String status) {
    if (status == 'approved') return Colors.green;
    if (status == 'rejected') return Colors.red;
    return const Color(0xFFB36B00);
  }

  Color _statusBackground(String status) {
    if (status == 'approved') return const Color(0xFFDDF8E8);
    if (status == 'rejected') return const Color(0xFFFFE1E1);
    return const Color(0xFFFFF3BE);
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
                  _topBar(context, 'My\nApplications'),
                  const SizedBox(height: 30),
                  FutureBuilder<List<ProgramApplication>>(
                    future: applicationsFuture,
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
                          'Could not load your applications',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      }

                      final applications = snapshot.data ?? [];

                      if (applications.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 30),
                          child: Text(
                            'You have not submitted any applications yet.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              height: 1.3,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: applications.map(_applicationCard).toList(),
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
    final status = application.status.toLowerCase();

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
              Icons.assignment_turned_in,
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
                  application.shortTitle.isEmpty
                      ? application.title
                      : application.shortTitle,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  application.email,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _statusBackground(status),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: _statusColor(status),
                fontWeight: FontWeight.bold,
              ),
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