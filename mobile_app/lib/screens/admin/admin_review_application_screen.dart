import 'package:flutter/material.dart';

import '../../models/program_application.dart';
import '../../repositories/application_repository.dart';
import '../../widgets/app_widgets.dart';

class AdminReviewApplicationScreen extends StatefulWidget {
  final ProgramApplication application;

  const AdminReviewApplicationScreen({
    super.key,
    required this.application,
  });

  @override
  State<AdminReviewApplicationScreen> createState() =>
      _AdminReviewApplicationScreenState();
}

class _AdminReviewApplicationScreenState
    extends State<AdminReviewApplicationScreen> {
  final ApplicationRepository applicationRepository = ApplicationRepository();

  bool isLoading = false;

  Future<void> approveApplication() async {
    setState(() => isLoading = true);

    try {
      await applicationRepository.approveApplication(
        applicationId: widget.application.applicationId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application approved successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> rejectApplication() async {
    setState(() => isLoading = true);

    try {
      await applicationRepository.rejectApplication(
        applicationId: widget.application.applicationId,
        notes: 'Rejected by administrator',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application rejected')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;

    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'Review\nApplication'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _info('Applicant', application.fullName),
                      _info('Email', application.email),
                      _info('Program', application.shortTitle),
                      _info(
                        'Age',
                        application.age?.toString() ?? 'Not provided',
                      ),
                      _info(
                        'Profession',
                        application.profession ?? 'Not provided',
                      ),
                      _info('Goals', application.goals ?? 'Not provided'),
                      _info('Status', application.status.toUpperCase()),
                      const SizedBox(height: 20),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: approveApplication,
                            child: const Text(
                              'Approve Application',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300,
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: rejectApplication,
                            child: const Text('Reject Application'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 17)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
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
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}