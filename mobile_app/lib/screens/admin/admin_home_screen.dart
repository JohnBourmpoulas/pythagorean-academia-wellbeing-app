import 'package:flutter/material.dart';

import '../../models/app_user.dart';
import '../../repositories/admin_repository.dart';
import '../../repositories/auth_repository.dart';
import '../../widgets/app_widgets.dart';
import '../auth/login_screen.dart';
import 'admin_applications_screen.dart';
import 'admin_programs_screen.dart';
import 'admin_messages_screen.dart';
import 'library/admin_library_screen.dart';
import 'tasks/admin_tasks_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final AppUser user;

  const AdminHomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final AdminRepository adminRepository = AdminRepository();
  final AuthRepository authRepository = AuthRepository();

  late Future<Map<String, int>> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = adminRepository.getAdminDashboardStats();
  }

  Future<void> refreshStats() async {
    setState(() {
      statsFuture = adminRepository.getAdminDashboardStats();
    });
  }

  Future<void> logout() async {
    await authRepository.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> openApplications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminApplicationsScreen()),
    );

    refreshStats();
  }

  Future<void> openPrograms() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminProgramsScreen()),
    );

    refreshStats();
  }

  Future<void> openLibrary() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminLibraryScreen()),
    );

    refreshStats();
  }



  Future<void> openDailyTasks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminTasksScreen()),
    );

    refreshStats();
  }

  Future<void> openMessages() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminMessagesScreen()),
    );

    refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Admin\nDashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1.15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: logout,
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  FutureBuilder<Map<String, int>>(
                    future: statsFuture,
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
                          'Error loading dashboard data',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        );
                      }

                      final stats = snapshot.data ??
                          {
                            'total_users': 0,
                            'pending_applications': 0,
                            'active_programs': 0,
                          };

                      return Column(
                        children: [
                          _dashboardCard(
                            Icons.groups,
                            'Total Users',
                            stats['total_users'].toString(),
                          ),
                          _dashboardCard(
                            Icons.assignment_turned_in,
                            'Pending\nApplications',
                            stats['pending_applications'].toString(),
                          ),
                          _dashboardCard(
                            Icons.monitor_heart,
                            'Active Programs',
                            stats['active_programs'].toString(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    text: 'Applications Queue',
                    onPressed: openApplications,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'My Programs',
                    onPressed: openPrograms,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Library Management',
                    onPressed: openLibrary,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Daily Tasks / Program Builder',
                    onPressed: openDailyTasks,
                  ),
                  const SizedBox(height: 14),
                  PrimaryButton(
                    text: 'Messages',
                    onPressed: openMessages,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dashboardCard(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(icon, color: const Color(0xFF2F61D2), size: 30),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 18,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}